/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import AuthenticationServices
import Combine

class WebAuthenticator: NSObject {
    
    var authURL: URL
    var callbackURLScheme: String

    init(authURL: URL, callbackURLScheme: String) {
        self.authURL = authURL
        self.callbackURLScheme = callbackURLScheme
    }
    
    var publisher: AnyPublisher<URL, Error> {
        Deferred {
            Future<URL, Error> { [weak self] result in
                guard let self = self else {
                    return result(.failure(WebAuthenticatorError.invalidState))
                }
                let session = ASWebAuthenticationSession(url: self.authURL, callbackURLScheme: self.callbackURLScheme) { (url, error) in
                    if let error = error {
                        result(.failure(error))
                    } else if let url = url {
                        result(.success(url))
                    }
                    else {
                        return result(.failure(WebAuthenticatorError.invalidState))
                    }
                }
                session.presentationContextProvider = self
                guard session.canStart, session.start() else {
                    return result(.failure(WebAuthenticatorError.invalidState))
                }
            }
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

extension WebAuthenticator: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

extension WebAuthenticator {
    enum WebAuthenticatorError: Swift.Error {
        case invalidState
    }
}
