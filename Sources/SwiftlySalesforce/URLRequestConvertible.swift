//
//  URLRequestConvertible.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

public protocol URLRequestConvertible {
    func request(with credential: Credential) throws -> URLRequest
}

public extension URLRequestConvertible {
    
    func request(
        credential: Credential,
        urlComponents: URLComponents,
        headers: [String: String]? = nil,
        method: HTTPMethod = .get,
        body: Data? = nil) throws -> URLRequest {
        
        // URL
        var comps = urlComponents
        comps.host = comps.host ?? credential.instanceURL.host
        comps.scheme = comps.scheme ?? credential.instanceURL.scheme
        comps.percentEncodedQuery = comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = comps.url else {
            throw URLError(URLError.badURL)
        }
        
        // URL Request
        var req = URLRequest(url: url)
        req.httpBody = body
        req.httpMethod = method.rawValue
        
        // Headers
        let defaultHeaders: [String: String] = [
            "Authorization": "Bearer \(credential.accessToken)",
            "Accept": "application/json",
            "Content-Type": {
                switch method {
                case .get, .delete: return "application/x-www-form-urlencoded; charset=utf-8"
                default: return "application/json"
                }
            }()
        ]
        req.allHTTPHeaderFields = defaultHeaders.merging(headers ?? [:]) { (_, new) in new }
        
        return req
    }
}

