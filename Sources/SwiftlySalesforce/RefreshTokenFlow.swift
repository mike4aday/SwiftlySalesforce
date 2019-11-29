//
//  RefreshTokenFlow.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

public struct RefreshTokenFlow {
}

extension RefreshTokenFlow: Refresher {
    
    public func publisher(credential: Credential, connectedApp: ConnectedApp, hostname: String) -> AnyPublisher<Credential, Error> {
        
        // Shorthand way to return error publisher
        let fail = { (error: Error) in Fail(outputType: Credential.self, failure: error).eraseToAnyPublisher() }
        
        // Salesforce OAuth2 refresh token endpoint URL
        guard let url = URL(string: "https://\(hostname)/services/oauth2/token") else {
            return fail(RefreshTokenFlowError.invalidEndpointURL)
        }
        
        // Encoded body data to be posted to OAuth refresh endpoint
        guard let refreshToken = credential.refreshToken else {
            return fail(RefreshTokenFlowError.invalidRequest(message: "Missing refresh token"))
        }
        let params: [String: String] = [
            "format" : "json",
            "grant_type": "refresh_token",
            "client_id": connectedApp.consumerKey,
            "refresh_token": refreshToken]
        guard let body = params.asPercentEncodedString()?.data(using: .utf8) else {
            return fail(RefreshTokenFlowError.invalidRequest(message: nil))
        }
        
        // Build URL request
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        req.httpMethod = HTTPMethod.post.rawValue
        req.httpBody = body
    
        // Publisher for request
        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    // Try to decode error information from data
                    if let err = try? JSONDecoder().decode(RefreshTokenFlowErrorResult.self, from: data)   {
                        throw RefreshTokenFlowError.endpointFailure(code: err.error, description: err.error_description, response: response)
                    }
                    else {
                        throw RefreshTokenFlowError.endpointFailure(code: "Unknown", description: nil, response: response)
                    }
                }
                return data
            }
            .decode(type: RefreshTokenFlowResult.self, decoder: JSONDecoder())
            .map { $0.refreshing(credential: credential) }
            .eraseToAnyPublisher()
    }
}

public enum RefreshTokenFlowError: LocalizedError {
    case invalidEndpointURL
    case invalidRequest(message: String?)
    case endpointFailure(code: String, description: String?, response: URLResponse)
}

fileprivate struct RefreshTokenFlowResult {
    
    let accessToken: String
    let instanceURL: URL
    let identityURL: URL
    let issuedAt: UInt?
    let communityURL: URL?
    let communityID: String?
    
    func refreshing(credential: Credential) -> Credential {
        return Credential(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: credential.refreshToken, issuedAt: issuedAt, idToken: credential.idToken, communityURL: communityURL, communityID: communityID)
    }
}

extension RefreshTokenFlowResult: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case instanceURL = "instance_url"
        case identityURL = "id"
        case issuedAt = "issued_at"
        case communityURL = "sfdc_community_url"
        case communityID = "sfdc_community_id"
    }
    
    public init(from decoder: Decoder) throws {
        
        // Top level container
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Set properties
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.instanceURL = try container.decode(URL.self, forKey: .instanceURL)
        self.identityURL = try container.decode(URL.self, forKey: .identityURL)
        self.issuedAt = try {
            guard let s = try container.decodeIfPresent(String.self, forKey: .issuedAt) else {
                return nil
            }
            return UInt(s)
        }()
        self.communityURL = try container.decodeIfPresent(URL.self, forKey: .communityURL)
        self.communityID = try container.decodeIfPresent(String.self, forKey: .communityID)
    }
}

fileprivate struct RefreshTokenFlowErrorResult: Decodable {
    var error: String
    var error_description: String?
}
