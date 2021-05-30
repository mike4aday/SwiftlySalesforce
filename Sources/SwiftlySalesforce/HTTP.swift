/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct HTTP {
    
    struct Method {
        static let get = "GET"
        static let delete = "DELETE"
        static let post = "POST"
        static let patch = "PATCH"
        static let head = "HEAD"
        static let put = "PUT"
    }
    
    struct MIMEType {
        static let json = "application/json"
        static let formUrlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
    }
    
    struct Header {
        static func accept(_ mimeType: String) -> (String, String) {
            return ("Accept", mimeType)
        }
        static func contentType(_ mimeType: String) -> (String, String) {
            return ("Content-Type", mimeType)
        }
        static func authorization(accessToken: String) -> (String, String) {
            return ("Authorization", "Bearer \(accessToken)")
        }
    }
}
