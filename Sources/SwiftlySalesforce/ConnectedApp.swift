/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

/// Represents a Salesforce Connected App.
/// # Reference
/// [Connected Apps](https://help.salesforce.com/articleView?id=sf.connected_app_overview.htm&type=5) in Salesforce help

public struct ConnectedApp {
    internal var credentialManager: CredentialManager
}

public extension ConnectedApp {
    
    /// Initializes a Connected App representation
    /// - Parameter url: URL to JSON configuration file. If nil, a file called `Salesforce.json` in the main app bundle is used by default.
    /// - Throws: Error if the JSON configuration data cannot be decoded.
    init(url: URL? = nil) throws {
        guard let url = url ?? Bundle.main.url(forResource: "Salesforce", withExtension: "json") else {
            throw URLError(.badURL)
        }
        let config = try JSONDecoder().decode(Configuration.self, from: try Data(contentsOf: url))
        self.init(configuration: config)
    }
    
    /// Initializes a Connected App representation
    /// - Parameters:
    ///   - consumerKey: The consumer key from your Connected App definition
    ///   - callbackURL: The callback URL from your Connected App definition
    ///   - defaultAuthHost: Hostname for OAuth authentication. Default is "login.salesforce.com". For sandbox orgs use "test.salesforce.com" or for a custom domain use, for example "somethingReallycool.my.salesforce.com"
    ///
    /// # Reference
    /// [Customize Your Login Process with My Domain](https://trailhead.salesforce.com/en/content/learn/modules/identity_login/identity_login_my_domain)
    init(consumerKey: String, callbackURL: URL, defaultAuthHost: String = "login.salesforce.com") {
        let mgr = CredentialManager(consumerKey: consumerKey, callbackURL: callbackURL, defaultHost: defaultAuthHost)
        self.init(credentialManager: mgr)
    }
    
    /// Logs in a new user and returns the new credential
    /// - Returns: Publisher
    func logIn() -> AnyPublisher<Credential, Error> {
        credentialManager.grantCredential(replacing: nil, allowsLogin: true)
    }

    /// Revokes a user's refresh and/or access tokens and clears the credential from the local, secure cache.
    /// - Parameter user: Identifier for the specified user or, if nil, the last authenticated user. (UserIdentifier is an alias for the user's identity URL.)
    /// - Returns: A publisher that completes when the underlying OAuth2 token revoke request completes.
    ///
    /// # Reference
    /// - [Identity URL](https://help.salesforce.com/articleView?id=sf.remoteaccess_using_openid.htm&type=5)
    /// - [Revoke OAuth Tokens](https://help.salesforce.com/articleView?id=sf.remoteaccess_revoke_token.htm&type=5)
    func logOut(user: UserIdentifier? = nil) -> AnyPublisher<Void, Error> {
        AnyPublisher<Credential?, Error>
            .just(try credentialManager.getStoredCredential(for: user))
            .compactMap { $0 }
            .flatMap { credentialManager.revokeCredential($0) }
            .onCompletion { _ in try? credentialManager.clearStoredCredential(for: user) } // Just in case store wasn't already cleared
            .eraseToAnyPublisher()
    }
    
    /// Gets the Credential for the specified user or, if no user is specified, then for the last authenticated user.
    /// - Parameters:
    ///   - user: Identifier for the specified user or, if nil, the last authenticated user. (UserIdentifier is an alias for the user's identity URL.)
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: A publisher of a Credential
    /// # Reference
    /// - [Identity URL](https://help.salesforce.com/articleView?id=sf.remoteaccess_using_openid.htm&type=5)
    /// - [OAuth 2.0 User-Agent Flow](https://help.salesforce.com/articleView?id=sf.remoteaccess_oauth_user_agent_flow.htm&type=5)
    func getCredential(for user: UserIdentifier? = nil, allowsLogin: Bool = true) -> AnyPublisher<Credential, Error> {
        credentialManager.getCredential(for: user, allowsLogin: allowsLogin)
    }
    
    /// Executes an asynchronous request for data from a Salesforce API endpoint. You will likely not need to call this method directly.
    /// - Parameters:
    ///   - service: Service
    ///   - session: URL session
    ///   - user: User identifier
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    ///   - validator: Validator
    ///   - decoder: JSON decoder
    /// - Returns: Publisher of decoded output
    func go<S, Output>(
        service: S,
        session: URLSession = URLSession.shared,
        user: UserIdentifier? = nil,
        allowsLogin: Bool = true,
        validator: Validator = .default,
        decoder: JSONDecoder = .salesforce
    ) -> AnyPublisher<Output, Error> where S: Service, Output: Decodable {
        
        credentialManager.getCredential(for: user, allowsLogin: allowsLogin)
            .flatMap { credential in
                go(service: service, session: session, credential: credential, validator: validator, decoder: decoder)
                    .tryCatchUserAuthenticationRequiredError {
                        credentialManager.grantCredential(replacing: credential, allowsLogin: allowsLogin)
                            .flatMap { newCredential in
                                go(service: service, session: session, credential: newCredential, validator: validator, decoder: decoder)
                            }
                    }
            }
            .eraseToAnyPublisher()
    }
}
