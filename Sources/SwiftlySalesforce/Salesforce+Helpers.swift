//
//  Salesforce+Helpers.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

extension Salesforce {
    
    internal static func validate(data: Data, response: URLResponse) throws -> (data: Data, response: URLResponse) {
    
        guard let response = response as? HTTPURLResponse else {
            throw SalesforceError.invalidResponse
        }
        switch response.statusCode {
        case 200..<300:
            return (data, response)
        case 401:
            throw SalesforceError.authenticationRequired
        case 403:
            throw SalesforceError.unauthorized
        case let code:
            // Error - try to deseralize Salesforce-provided error information
            // See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
            if let err = try? JSONDecoder().decode(EndpointErrorResult.self, from: data) {
                throw SalesforceError.endpointFailure(statusCode: code, errorCode: err.errorCode, message: err.message, fields: err.fields)
            }
            else if let errs = try? JSONDecoder().decode([EndpointErrorResult].self, from: data), let err = errs.first {
                throw SalesforceError.endpointFailure(statusCode: code, errorCode: err.errorCode, message: err.message, fields: err.fields)
            }
            else {
                throw SalesforceError.endpointFailure(statusCode: code, errorCode: nil, message: "Salesforce resource error.", fields: nil)
            }
        }
    }
    
    internal func makeRequest<T: Decodable>(
        requestConvertible: URLRequestConvertible,
        validate: @escaping (Data, URLResponse) throws -> (Data, URLResponse) = Salesforce.validate,
        config: RequestConfig) -> AnyPublisher<T, Error> {
                
        // Closure that executes the request
        let _go = { (credential: Credential) -> AnyPublisher<T, Error> in
            guard let req = try? requestConvertible.request(with: credential) else {
                return Fail(error: SalesforceError.invalidRequest(message: "Unable to create request.")).eraseToAnyPublisher()
            }
            return config.session.dataTaskPublisher(for: req)
            .retry(config.retries)
            .tryMap {
                let (data, _) = try validate($0.data, $0.response)
                if (T.self == Data.self) {
                    return data as! T
                }
                else {
                    return try JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(T.self, from: data) 
                }
            }
            .eraseToAnyPublisher()
        }
        
        return Just(self.credential)
        .tryMap { (cred) -> Credential in
            guard let cred = cred else {
                throw SalesforceError.authenticationRequired
            }
            return cred
        }
        .tryCatch { _ in
            self.requestCredential(refreshing: nil, authenticateIfRequired: config.authenticateIfRequired)
        }
        .flatMap { credential in
            return _go(credential)
            .tryCatch { (error) -> AnyPublisher<T, Error> in
                guard case SalesforceError.authenticationRequired = error else {
                    throw error
                }
                return self.requestCredential(refreshing: credential, authenticateIfRequired: config.authenticateIfRequired)
                .flatMap { newCred in
                    _go(newCred)
                }
                .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    internal func requestCredential(refreshing credential: Credential?, authenticateIfRequired: Bool) -> AnyPublisher<Credential, Error> {
        
        Just(credential)
        .tryMap { (oldCred) -> Credential in
            guard let oldCred = oldCred else {
                // We don't have an invalid credential to refresh, so authentication is required
                throw SalesforceError.authenticationRequired
            }
            return oldCred
        }
        .flatMap { oldCred in
            // Attempt to refresh invalid credential
            self.oAuthManager.refresh(credential: oldCred)
        }
        .tryCatch { (error) -> AnyPublisher<Credential, Error> in
            // Attempt to refresh credential failed...
            guard authenticateIfRequired else {
                // Caller doesn't want to authenticate, so just re-throw error
                throw error
            }
            // ...so authenticate
            return self.oAuthManager.authenticate()
        }
        .map { (newCred) -> Credential in
            // Store new credential securely and publish it
            try? self.credentialStore.store(newCred)
            return newCred
        }
        .eraseToAnyPublisher()
    }
}

// MARK: --

fileprivate struct EndpointErrorResult: Decodable {
    var message: String
    var errorCode: String
    var fields: [String]?
}
