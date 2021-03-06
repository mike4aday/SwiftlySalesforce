/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

struct RefreshTokenFlow {
    var refreshToken: String
    var consumerKey: String
    var host: String
    var session: URLSession = URLSession(configuration: .ephemeral)
    var validator: Validator = .default
}

extension RefreshTokenFlow {
    
    var publisher: AnyPublisher<Credential, Error> {
        AnyPublisher<URLRequest?, Error>
            .just(URLRequest.refreshTokenFlow(refreshToken: refreshToken, consumerKey: consumerKey, host: host))
            .unwrap(orThrow: URLError(.badURL))
            .flatMap { session.dataTaskPublisher(for: $0).mapError { $0 as Error } }
            .validate(using: validator.validate)
            .map { String(data: $0.data, encoding: .utf8) }
            .unwrap(orThrow: URLError(.cannotDecodeRawData))
            .map { Credential(fromURLEncodedString: $0, andRefreshToken: refreshToken) }
            .unwrap(orThrow: URLError(.badServerResponse))
            .eraseToAnyPublisher()
    }
}
