/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct SalesforceError: Error, Decodable, Equatable {
    
    public var code: String
    public var message: String
    public var fields: [String]? = nil
    
    enum CodingKeys: String, CodingKey {
        case code = "errorCode"
        case message
        case fields
    }
    
    static let userAuthenticationRequired = SalesforceError(code: "INVALID_SESSION_ID", message: "Session expired or invalid.")
    
    static func responseError(response: HTTPURLResponse) -> Self {
        let code = "HTTP status code: \(response.statusCode)"
        let msg = "There was an error. Requested URL: \(response.url?.absoluteString ?? "not available")."
        return SalesforceError(code: code, message: msg)
    }
}

extension SalesforceError: LocalizedError {
        
    public var errorDescription: String? {
        return NSLocalizedString(message, comment: code)
    }
}
