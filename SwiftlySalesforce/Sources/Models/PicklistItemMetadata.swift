//
//  PicklistItemMetadata.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

/// Represents options in a Salesforce Picklist-type field (i.e. drop-down list)
public struct PicklistItemMetadata: Decodable {
	
	public let isActive: Bool
	public let isDefault: Bool
	public let label: String
	public let value: String
	
	enum CodingKeys: String, CodingKey {
		case isActive = "active"
		case isDefault = "defaultValue"
		case label
		case value
	}
}
