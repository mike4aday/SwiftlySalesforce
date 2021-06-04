/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import AuthenticationServices

internal extension ConnectedApp {
    
    init(configuration config: Configuration) {
        var mgr = CredentialManager(consumerKey: config.consumerKey, callbackURL: config.callbackURL)
        if let defaultHost = config.defaultAuthHost {
            mgr.defaultHost = defaultHost
        }
        self.init(credentialManager: mgr)
    }
    
    func go<Output>(service: Service, session: URLSession, credential: Credential, validator: Validator, decoder: JSONDecoder) -> AnyPublisher<Output, Error> where Output: Decodable {
        AnyPublisher<URLRequest, Error>.just(try service.buildRequest(with: credential))
            .flatMap { session.dataTaskPublisher(for: $0).mapError { $0 as Error } }
            .validate(using: validator.validate)
            .map(\.data)
            .tryMap { data in
                if let output = data as? Output {
                    return output
                }
                else {
                    return try decoder.decode(Output.self, from: data)
                }
            }
            .eraseToAnyPublisher()
    }
}
