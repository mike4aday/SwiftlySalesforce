/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public extension JSONEncoder {
    
    static var salesforce: JSONEncoder = JSONEncoder(dateEncodingStrategy: .formatted(.salesforce(.long)))
    
    convenience init(dateEncodingStrategy: DateEncodingStrategy) {
        self.init()
        self.dateEncodingStrategy = dateEncodingStrategy
    }
}
