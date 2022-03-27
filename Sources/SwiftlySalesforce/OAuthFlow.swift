import Foundation

struct OAuthFlow {
    
    static func userAgent(
        consumerKey: String,
        host: String,
        callbackURL: URL
    ) async throws -> Credential {
            
        let authURL = try URL.userAgentFlow(host: host, clientID: consumerKey, callbackURL: callbackURL)
        guard let scheme = callbackURL.scheme else {
            throw URLError(.badURL, userInfo: [NSURLErrorFailingURLStringErrorKey: callbackURL])
        }
        let redirectURL = try await WebAuthenticationSession.shared.start(url: authURL, callbackURLScheme: scheme)
        return try parse(encodedString: redirectURL.fragment) {
            Credential(fromPercentEncoded: $0)
        }
    }
    
    static func refreshToken(
        consumerKey: String,
        host: String,
        refreshToken: String,
        session: URLSession = URLSession(configuration: .ephemeral)
    ) async throws -> Credential {
    
        let req = try URLRequest.refreshTokenFlow(host: host, clientID: consumerKey, refreshToken: refreshToken)
        let (response, _) = try await session.data(for: req)
        return try parse(encodedString: String(data: response)) {
            Credential(fromPercentEncoded: $0, andRefreshToken: refreshToken)
        }
    }
    
    static func revokeToken(
        host: String,
        token: String,
        session: URLSession = URLSession(configuration: .ephemeral)
    ) async throws -> Void {
        
        let req = try URLRequest.revokeTokenFlow(host: host, token: token)
        let (response, _) = try await session.data(for: req)
        return try parse(encodedString: String(data: response)) {
             $0 == "" ? Void() : nil
        }
    }
}

private extension OAuthFlow {
    
    static func parse<T>(encodedString: String?, with parser: (String) -> T?) throws -> T {
        if let t = encodedString.flatMap({ parser($0) }) {
            return t
        }
        if let err = encodedString.flatMap({ OAuthError(fromPercentEncodedString: $0) }) {
            throw err
        }
        throw URLError(.badServerResponse)
    }
}
