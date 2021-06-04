/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public extension URLComponents {
    
    init(scheme: String = "https", host: String, path: String, queryParameters: Dictionary<String, String>? = nil) {
        self.init()
        self.scheme = scheme
        self.host = host
        self.path = path
        if let params = queryParameters {
            self.queryItems = .init(params)
        }
    }
    
    init(percentEncodedQuery: String) {
        self.init()
        self.percentEncodedQuery = percentEncodedQuery
    }
}
