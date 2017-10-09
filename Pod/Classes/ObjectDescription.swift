//
//  ObjectDescription.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

/// Salesforce object metadata
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm
public struct ObjectDescription {
	
	public let fields: [String: FieldDescription]
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
}

extension ObjectDescription: Decodable {
	
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
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		var fieldsDict = [String: FieldDescription]()
		if let fieldsArray = try container.decodeIfPresent([FieldDescription].self, forKey: .fields) {
			for field in fieldsArray {
				fieldsDict[field.name] = field
			}
		}
		
		// Set properties
		self.fields = fieldsDict
		self.isCreateable = try container.decode(Bool.self, forKey: .isCreateable)
		self.isCustom = try container.decode(Bool.self, forKey: .isCustom)
		self.isCustomSetting = try container.decode(Bool.self, forKey: .isCustomSetting)
		self.isDeletable = try container.decode(Bool.self, forKey: .isDeletable)
		self.isFeedEnabled = try container.decode(Bool.self, forKey: .isFeedEnabled)
		self.isQueryable = try container.decode(Bool.self, forKey: .isQueryable)
		self.isSearchable = try container.decode(Bool.self, forKey: .isSearchable)
		self.isTriggerable = try container.decode(Bool.self, forKey: .isTriggerable)
		self.isUndeletable = try container.decode(Bool.self, forKey: .isUndeletable)
		self.isUpdateable = try container.decode(Bool.self, forKey: .isUpdateable)
		self.keyPrefix = try container.decodeIfPresent(String.self, forKey: .keyPrefix)
		self.label = try container.decode(String.self, forKey: .label)
		self.labelPlural = try container.decode(String.self, forKey: .labelPlural)
		self.name = try container.decode(String.self, forKey: .name)
	}
}

