/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

struct RevokeTokenFlow {
    var token: String
    var host: String
    var session: URLSession = URLSession(configuration: .ephemeral)
    var validator: Validator = .default
}

extension RevokeTokenFlow {
    
    var publisher: AnyPublisher<Void, Error> {
        AnyPublisher<URLRequest?, Error>
            .just(URLRequest.revokeTokenFlow(token: token, host: host))
            .unwrap(orThrow: URLError(.badURL))
            .flatMap { session.dataTaskPublisher(for: $0).mapError { $0 as Error } }
            .validate(using: validator.validate)
            .map { _ in return }
            .eraseToAnyPublisher()
    }
}
