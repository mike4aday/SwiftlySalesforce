/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

// Swiftly Salesforce uses the identity URL as a unique user identifier
// See: https://help.salesforce.com/articleView?id=sf.remoteaccess_using_openid.htm&type=5
public typealias UserIdentifier = URL

extension UserIdentifier {
    
    init?(host: String = "login.salesforce.com", userID: String, orgID: String) {
        self.init(string: "https://\(host)/id/\(orgID)/\(userID)")
    }
}
