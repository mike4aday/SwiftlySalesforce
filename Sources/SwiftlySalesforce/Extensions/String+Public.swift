/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public extension String {
    
    init?(byURLEncoding params: Dictionary<String, String>){
        var comps = URLComponents()
        comps.queryItems = .init(params)
        if let s = comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B") {
            self = s
        }
        else {
            return nil
        }
    }
}
