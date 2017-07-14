//
//  PicklistItem.swift
//  SwiftlySalesforce
//
//	For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Represents options in a Salesforce Picklist-type field (i.e. drop-down list)
public struct PicklistItem {
	
	public let isActive: Bool
	public let isDefault: Bool
	public let label: String
	public let value: String
	
	public init(json: [String: Any]) throws {
		
		guard
			let isActive = json["active"] as? Bool,
			let isDefault = json["defaultValue"] as? Bool,
			let label = json["label"] as? String,
			let value = json["value"] as? String else {
				
				throw SerializationError.invalid(json, message: "Unable to create PicklistItem")
		}
		
		self.isActive = isActive
		self.isDefault = isDefault
		self.label = label
		self.value = value
	}
}
