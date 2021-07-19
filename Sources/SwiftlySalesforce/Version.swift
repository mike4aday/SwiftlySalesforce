/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

/// Represents the version of the Salesforce API used by Swiftly Salesforce
public struct Version {
    public var major: Int = 52 // Summer '21
    public var minor: Int = 0
    public static var `default` = Version()
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor)"
    }
}
