import Foundation

actor DefaultAuthorizer {
    
    let consumerKey: String
    let callbackURL: URL
    let defaultHost: String

    private var authenticatingTask: Task<Credential, Error>?
    private var revokingTask: Task<Void, Error>?
    
    init(consumerKey: String, callbackURL: URL, session: URLSession? = nil, defaultHost: String? = nil) {
        self.consumerKey = consumerKey
        self.callbackURL = callbackURL
        self.defaultHost = defaultHost ?? "login.salesforce.com"
    }
}

//MARK: - Authenticator conformance -
extension DefaultAuthorizer: Authorizer {

    func grantCredential(refreshing: Credential? = nil) async throws -> Credential {
        if let task = authenticatingTask {
            return try await task.value
        }
        let task: Task<Credential, Error> = Task {
            defer { self.authenticatingTask = nil }
            let host = refreshing?.siteURL?.host ?? refreshing?.instanceURL.host ?? defaultHost
            guard let credential = refreshing, let refreshToken = credential.refreshToken else {
                return try await OAuthFlow.userAgent(consumerKey: consumerKey, host: host, callbackURL: callbackURL)
            }
            do {
                return try await OAuthFlow.refreshToken(consumerKey: consumerKey, host: host, refreshToken: refreshToken)
            }
            catch {
                return try await OAuthFlow.userAgent(consumerKey: consumerKey, host: host, callbackURL: callbackURL)
            }
        }
        self.authenticatingTask = task
        return try await task.value
    }
    
    func revoke(credential: Credential) async throws {
        if let task = revokingTask {
            return try await task.value
        }
        let task: Task<Void, Error> = Task {
            defer { self.revokingTask = nil }
            let host = credential.siteURL?.host ?? credential.instanceURL.host ?? defaultHost
            let token = credential.refreshToken ?? credential.accessToken
            return try await OAuthFlow.revokeToken(host: host, token: token)
        }
        self.revokingTask = task
        return try await task.value
    }
}
