import Foundation

public struct Salesforce {
    
    public static func connect(configurationURL: URL? = nil, session: URLSession = .shared) throws -> Connection {
        
        guard let url =
                configurationURL
                ?? Bundle.main.url(forResource: "Salesforce", withExtension: "json")
                ?? Bundle.main.url(forResource: "salesforce", withExtension: "json") else {
                throw URLError(.badURL, userInfo: [NSURLErrorFailingURLStringErrorKey : "Salesforce.json"])
        }
        let config = try JSONDecoder().decode(Configuration.self, from: try Data(contentsOf: url))
        return try connect(consumerKey: config.consumerKey, callbackURL: config.callbackURL, authorizingHost: config.authorizingHost, session: session)
    }
    
    public static func connect(consumerKey: String, callbackURL: URL, authorizingHost: String? = nil, session: URLSession = .shared) throws -> Connection {
        
        let authorizer = DefaultAuthorizer(consumerKey: consumerKey, callbackURL: callbackURL, defaultHost: authorizingHost)
        let credentialStore = DefaultCredentialStore(consumerKey: consumerKey)
        guard let defaults = UserDefaults(suiteName: consumerKey) else {
            throw StateError("Failed to initialize user defaults")
        }
        return try connect(authorizer: authorizer, credentialStore: credentialStore, defaults: defaults, session: session)
    }
    
    public static func connect(authorizer: Authorizer, credentialStore: CredentialStore, defaults: UserDefaults, session: URLSession) throws -> Connection {
        return Connection(authorizer: authorizer, credentialStore: credentialStore, defaults: defaults, session: session)
    }
}

internal extension Salesforce {
    
    struct Configuration: Decodable {
    
        let consumerKey: String
        let callbackURL: URL
        let authorizingHost: String?
    }
}
