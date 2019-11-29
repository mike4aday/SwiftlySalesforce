//
//  UserAgentFlow.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine
import AuthenticationServices

/// See [Understanding the User-Agent OAuth Authentication Flow](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_user_agent_oauth_flow.htm)
public struct UserAgentFlow {
    static internal var activeSubject: (subject: PassthroughSubject<Credential, Error>, consumerKey: String)?
}

extension UserAgentFlow: Authenticator {
    
    public func publisher(connectedApp: ConnectedApp, hostname: String) -> AnyPublisher<Credential, Error> {
        
        // OAuth parameters
        let parameters = [
            "response_type" : "token",
            "client_id" : connectedApp.consumerKey,
            "redirect_uri" : connectedApp.callbackURL.absoluteString,
            "prompt" : "login consent",
            "display" : "touch" ]
        
        // Salesforce OAuth2 authentication endpoint URL
        var comps = URLComponents(string: "https://\(hostname)/services/oauth2/authorize")
        comps?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let authURL = comps?.url else {
            return Fail(error: UserAgentFlowError.invalidEndpointURL).eraseToAnyPublisher()
        }
        
        if let subj = UserAgentFlow.activeSubject {
            if (subj.consumerKey == connectedApp.consumerKey) {
                // Reusing existing subject for user-agent flow
                return subj.subject.eraseToAnyPublisher()
            }
            else {
                return Fail(error: UserAgentFlowError.authenticationInProgress).eraseToAnyPublisher()
            }
        }
        else {
            // Creating new subject for user-agent flow
            let subj = PassthroughSubject<Credential, Error>()
            UserAgentFlow.activeSubject = (subj, connectedApp.consumerKey)
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: connectedApp.callbackURL.scheme) { (url, error) in
                UserAgentFlow.activeSubject = nil
                if let error = error {
                    // User cancelled authentication, or something else went wrong
                    subj.send(completion: .failure(error))
                }
                else {
                    // User denied access, or something else went wrong that didn't raise an
                    // error but still didn't result in a proper callback URL with appended credential
                    if let url = url, let cred = try? Credential(with: url) {
                        subj.send(cred)
                        subj.send(completion: .finished)
                    }
                    else {
                        subj.send(completion: .failure(UserAgentFlowError.unparseableCallbackURL))
                    }
                }
            }
            DispatchQueue.main.async {
                let contextProvider = KeyWindowPresentationAnchor()
                session.presentationContextProvider = contextProvider
                //session.prefersEphemeralWebBrowserSession = true
                //TODO: setting above to 'true' causes problems if authentication controllers
                //are displayed in rapid succession
                if !session.start() {
                    subj.send(completion: .failure(UserAgentFlowError.sessionFailure))
                    UserAgentFlow.activeSubject = nil 
                }
            }
            return subj.eraseToAnyPublisher()
        }
    }
}

public enum UserAgentFlowError: LocalizedError {
    case invalidEndpointURL
    case unparseableCallbackURL
    case sessionFailure
    case authenticationInProgress
}

fileprivate class KeyWindowPresentationAnchor: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        var anchor: ASPresentationAnchor?
        #if canImport(UIKit)
            anchor = UIApplication.shared.windows.first { $0.isKeyWindow }
        #endif
        guard let returnMe = anchor else {
            fatalError("Failed to get key window for authentication session!")
        }
        return returnMe
    }
}
