/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

struct Configuration {
    var consumerKey: String
    var callbackURL: URL
    var defaultAuthHost: String?
}

extension Configuration: Decodable {
    enum CodingKeys: String, CodingKey {
        case consumerKey = "ConsumerKey"
        case callbackURL = "CallbackURL"
        case defaultAuthHost = "DefaultAuthHost"
    }
}
