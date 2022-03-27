import Foundation

/// Represents a limited Salesforce resource.
/// See: [Limits](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm).
public struct Limit {
    
    public let maximum: Int
    public let remaining: Int
}

public extension Limit {
    
    var used: Int {
        return maximum - remaining
    }
}

extension Limit: Codable {
    
    enum CodingKeys: String, CodingKey {
        case maximum = "Max"
        case remaining = "Remaining"
    }
}
