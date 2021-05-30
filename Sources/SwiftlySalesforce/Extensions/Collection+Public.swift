/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public extension Collection where Element == URLQueryItem {
    
    // Borrowed from https://www.avanderlee.com/swift/url-components/
    subscript(_ name: String) -> String? {
        first(where: { $0.name == name })?.value
    }
}
