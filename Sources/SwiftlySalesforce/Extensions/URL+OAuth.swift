import Foundation

public extension URL {
    
    static func userAgentFlow(
        host: String,
        clientID: String,
        callbackURL: URL,
        state: String? = nil,
        loginHint: String? = nil,
        display: String = "touch",
        prompt: String = "login consent") throws -> Self {
            
        let path = "/services/oauth2/authorize"
        var parameters = [
            "response_type" : "token",
            "client_id" : clientID,
            "redirect_uri" : callbackURL.absoluteString,
            "prompt" : prompt,
            "display" : display
        ]
        state.map { parameters["state"] = $0 }
        loginHint.map { parameters["login_hint"] = $0 }
            
        guard let url = URLComponents(host: host, path: path, queryParameters: parameters).url else {
            throw URLError(.badURL)
        }
        return url
    }
}
