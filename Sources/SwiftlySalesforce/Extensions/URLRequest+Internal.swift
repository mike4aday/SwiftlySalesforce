/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

internal extension URLRequest {

    static func refreshTokenFlow(refreshToken: String, consumerKey: String, host: String) -> Self? {
        guard let url = URL.refreshTokenFlow(host: host) else {
            return nil
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        req.httpMethod = HTTP.Method.post
        let params: [String: String] = [
            "format" : "urlencoded",
            "grant_type": "refresh_token",
            "client_id": consumerKey,
            "refresh_token": refreshToken]
        guard let body = String(byURLEncoding: params)?.data(using: .utf8) else {
            return nil
        }
        req.httpBody = body
        req.setHTTPHeader(HTTP.Header.contentType(HTTP.MIMEType.formUrlEncoded))

        return req
    }
    
    static func revokeTokenFlow(token: String, host: String) -> Self? {
        guard let url = URL.revokeTokenFlow(host: host) else {
            return nil
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        req.httpMethod = HTTP.Method.post
        let params: [String: String] = ["token" : token]
        guard let body = String(byURLEncoding: params)?.data(using: .utf8) else {
            return nil
        }
        req.httpBody = body
        req.setHTTPHeader(HTTP.Header.contentType(HTTP.MIMEType.formUrlEncoded))

        return req
    }
}
