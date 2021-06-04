/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

extension URLRequest {
    
    mutating func setHTTPHeader(_ nameValuePair: (String, String?)) {
        setValue(nameValuePair.1, forHTTPHeaderField: nameValuePair.0)
    }
}
