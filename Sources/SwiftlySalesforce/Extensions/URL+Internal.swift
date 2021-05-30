/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

internal extension URL {
    
    init?(string: String?) {
        guard let string = string else {
            return nil
        }
        self.init(string: string)
    }
    
    static func userAgentFlow(host: String, consumerKey: String, callbackURL: URL) -> Self? {
        let host = host
        let path = "/services/oauth2/authorize"
        let parameters = [
            "response_type" : "token",
            "client_id" : consumerKey,
            "redirect_uri" : callbackURL.absoluteString,
            "prompt" : "login consent",
            "display" : "touch"
        ]
        return URLComponents(host: host, path: path, queryParameters: parameters).url
    }
    
    static func refreshTokenFlow(host: String) -> Self? {
        URL(string: "https://\(host)/services/oauth2/token")
    }
    
    static func revokeTokenFlow(host: String) -> Self? {
        URL(string: "https://\(host)/services/oauth2/revoke")
    }
}
