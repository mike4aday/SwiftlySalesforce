//
//  ObjectDescription.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

/// Salesforce object metadata
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm
public struct ObjectDescription: Decodable {
	
	public let fields: [FieldDescription]?
	public let isCreateable: Bool
	public let isCustom: Bool
	public let isCustomSetting: Bool
	public let isDeletable: Bool
	public let isFeedEnabled: Bool
	public let isQueryable: Bool
	public let isSearchable: Bool
	public let isTriggerable: Bool
	public let isUndeletable: Bool
	public let isUpdateable: Bool
	public let keyPrefix: String?
	public let label: String
	public let labelPlural: String
	public let name: String
	
	public var idPrefix: String? {
		return keyPrefix
	}
	
	public var pluralLabel: String {
		return labelPlural
	}
	
	enum CodingKeys: String, CodingKey {
		case fields
		case isCreateable = "createable"
		case isCustom = "custom"
		case isCustomSetting = "customSetting"
		case isDeletable = "deletable"
		case isFeedEnabled = "feedEnabled"
		case isQueryable = "queryable"
		case isSearchable = "searchable"
		case isTriggerable = "triggerable"
		case isUndeletable = "undeletable"
		case isUpdateable = "updateable"
		case keyPrefix
		case label
		case labelPlural
		case name
	}
}
