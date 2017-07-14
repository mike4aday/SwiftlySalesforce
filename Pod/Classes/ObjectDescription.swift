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
	
	public let fields: [String: FieldDescription]?
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
	
	public init(json: [String: Any]) throws {
		
		guard
			let isCreateable = json["createable"] as? Bool,
			let isCustom = json["custom"] as? Bool,
			let isCustomSetting = json["customSetting"] as? Bool,
			let isDeletable = json["deletable"] as? Bool,
			let isFeedEnabled = json["feedEnabled"] as? Bool,
			let isQueryable = json["queryable"] as? Bool,
			let isSearchable = json["searchable"] as? Bool,
			let isTriggerable = json["triggerable"] as? Bool,
			let isUndeletable = json["undeletable"] as? Bool,
			let isUpdateable = json["updateable"] as? Bool,
			let label = json["label"] as? String,
			let labelPlural = json["labelPlural"] as? String,
			let name = json["name"] as? String else {
			
			throw SerializationError.invalid(json, message: "Unable to create ObjectDesription")
		}
		
		self.fields = {
			if let fieldJsons = json["fields"] as? [[String: Any]], let fieldDescs = try? fieldJsons.map { try FieldDescription(json: $0) } {
				var dict = [String: FieldDescription]()
				for fieldDesc in fieldDescs {
					dict[fieldDesc.name] = fieldDesc
				}
				return dict
			}
			return nil
		}()
		self.isCreateable = isCreateable
		self.isCustom = isCustom
		self.isCustomSetting = isCustomSetting
		self.isDeletable = isDeletable
		self.isFeedEnabled = isFeedEnabled
		self.isQueryable = isQueryable
		self.isSearchable = isSearchable
		self.isTriggerable = isTriggerable
		self.isUndeletable = isUndeletable
		self.isUpdateable = isUpdateable
		self.keyPrefix = json["keyPrefix"] as? String
		self.label = label
		self.labelPlural = labelPlural
		self.name = name
	}
}
