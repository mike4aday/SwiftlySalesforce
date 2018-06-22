//
//  Limit.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

/// Represents a limited Salesforce resource
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
public struct Limit: Decodable {
	
	public let maximum: Int
	public let remaining: Int
	
	enum CodingKeys: String, CodingKey {
		case maximum = "Max"
		case remaining = "Remaining"
	}
}
