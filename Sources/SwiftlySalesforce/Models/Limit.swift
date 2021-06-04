//
//  File.swift
//  
//
//  Created by Michael Epstein on 4/23/21.
//

import Foundation

/// Represents a limited Salesforce resource.
/// See: [Limits](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm).
public struct Limit {
    public let maximum: Int
    public let remaining: Int
    var used: Int {
        return maximum - remaining
    }
}

extension Limit: Codable {
    public enum CodingKeys: String, CodingKey {
        case maximum = "Max"
        case remaining = "Remaining"
    }
}
