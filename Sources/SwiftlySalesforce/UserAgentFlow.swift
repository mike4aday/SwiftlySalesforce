/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import AuthenticationServices

struct UserAgentFlow {
    var host: String
    var consumerKey: String
    var callbackURL: URL 
}

extension UserAgentFlow {
    
    var publisher: AnyPublisher<Credential, Error> {
        guard let authURL = URL.userAgentFlow(host: host, consumerKey: consumerKey, callbackURL: callbackURL), let scheme = callbackURL.scheme else {
            return .fail(with: URLError(.badURL))
        }
        return WebAuthenticator(authURL: authURL, callbackURLScheme: scheme)
            .publisher
            .validate { augmentedCallbackURL in
                if let items = URLComponents(url: augmentedCallbackURL, resolvingAgainstBaseURL: false)?.queryItems,
                   let error = items["error"],
                   let desc = items["error_description"] {
                    throw SalesforceError(code: error, message: desc)
                }
            }
            .map { $0.fragment }
            .unwrap(orThrow: URLError(.badURL, userInfo: [NSURLErrorFailingURLErrorKey : authURL]))
            .map { Credential(fromURLEncodedString: $0) }
            .unwrap(orThrow: URLError(.badURL, userInfo: [NSURLErrorFailingURLErrorKey : authURL]))
            .eraseToAnyPublisher()
    }
}
