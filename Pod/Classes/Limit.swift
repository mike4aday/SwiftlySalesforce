//
//  Limit.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Represents a limited Salesforce resource
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
public struct Limit {
	
	public let name: String
	public let maximum: Int
	public let remaining: Int
	
	public init(name: String, json: [String: Any]) throws {
		guard let remaining = json["Remaining"] as? Int, let maximum = json["Max"] as? Int else {
			throw SerializationError.invalid(json, message: "Unable to create Limit")
		}
		self.name = name
		self.maximum = maximum
		self.remaining = remaining
	}
}
