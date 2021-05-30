/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct IdentityService: Service {
    
    public func buildRequest(with credential: Credential) throws -> URLRequest {
        var req = URLRequest(url: credential.identityURL)
        req.setHTTPHeader(HTTP.Header.authorization(accessToken: credential.accessToken))
        req.setHTTPHeader(HTTP.Header.accept(HTTP.MIMEType.json))
        return req
    }
}
