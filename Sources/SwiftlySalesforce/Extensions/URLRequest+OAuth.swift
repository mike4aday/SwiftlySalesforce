import Foundation

extension URLRequest {
    
    static func refreshTokenFlow(host: String, clientID: String, refreshToken: String) throws -> Self {
        
        guard let url = URL(string: "https://\(host)/services/oauth2/token") else {
            throw URLError(.badURL)
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        req.httpMethod = HTTP.Method.post
        let params: [String: String] = [
            "format" : "urlencoded",
            "grant_type": "refresh_token",
            "client_id": clientID,
            "refresh_token": refreshToken]
        guard let body = String(byPercentEncoding: params)?.data(using: .utf8) else {
            throw RequestError("Failed to create refresh token flow request")
        }
        req.httpBody = body
        req.setValue(HTTP.MIMEType.formUrlEncoded, forHTTPHeaderField: HTTP.Header.contentType)
        
        return req
    }
    
    static func revokeTokenFlow(host: String, token: String) throws -> Self {
        
        guard let url = URL(string: "https://\(host)/services/oauth2/revoke") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        req.httpMethod = HTTP.Method.post
        let params: [String: String] = ["token" : token]
        guard let body = String(byPercentEncoding: params)?.data(using: .utf8) else {
            throw RequestError("Failed to create revoke token flow request")
        }
        req.httpBody = body
        req.setValue(HTTP.MIMEType.formUrlEncoded, forHTTPHeaderField: HTTP.Header.contentType)

        return req
    }
}
