/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

internal extension UserDefaults {
    
    var user: UserIdentifier? {
        get {
            return url(forKey: #function)
        }
        set {
            guard let user = newValue else {
                return removeObject(forKey: #function)
            }
            set(user, forKey: #function)
        }
    }
    
    convenience init?(consumerKey: String) {
        self.init(suiteName: consumerKey)
    }
}
