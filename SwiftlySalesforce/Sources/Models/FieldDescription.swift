//
//  FieldDescription.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

/// Salesforce field metadata
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm

public struct FieldDescription {
	
	public let defaultValue: Any?
	public let defaultValueFormula: String?
	public let inlineHelpText: String?
	public let isCreateable: Bool
	public let isCustom: Bool
	public let isEncrypted: Bool
	public let isNillable: Bool
	public let isSortable: Bool
	public let isUpdateable: Bool
	public let label: String
	public let length: UInt?
	public let name: String
	public let picklistValues: [PicklistItem]
	public let relatedTypes: [String]
	public let relationshipName: String?
	public let type: String
	
	public var helpText: String? {
		return inlineHelpText
	}
	
	public var referenceTo: [String]? {
		return relatedTypes
	}
}

extension FieldDescription: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case defaultValue
		case defaultValueFormula
		case inlineHelpText
		case isCreateable = "createable"
		case isCustom = "custom"
		case isEncrypted = "encrypted"
		case isNillable = "nillable"
		case isSortable = "sortable"
		case isUpdateable = "updateable"
		case label
		case length
		case name
		case picklistValues
		case relatedTypes = "referenceTo"
		case relationshipName
		case type
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// 'defaultValue' can be either String (for Picklist-type fields) or Boolean (for Checkbox-type fields).
		// All other field types seem to store their default values in 'defaultValueFormula'...
		var defaultValue: Any? = nil
		if let f = try? container.decodeIfPresent(Bool.self, forKey: .defaultValue) {
			defaultValue = f
		}
		else if let s = try? container.decodeIfPresent(String.self, forKey: .defaultValue) {
			defaultValue = s
		}

		// Set properties
		self.defaultValue = defaultValue
		self.defaultValueFormula = try container.decodeIfPresent(String.self, forKey: .defaultValueFormula)	// Optional property
		self.inlineHelpText = try container.decodeIfPresent(String.self, forKey: .inlineHelpText) 			// Optional property
		self.isCreateable = try container.decode(Bool.self, forKey: .isCreateable)							// Required property
		self.isCustom = try container.decode(Bool.self, forKey: .isCustom)									// Required property
		self.isEncrypted = try container.decode(Bool.self, forKey: .isEncrypted)							// Required property
		self.isNillable = try container.decode(Bool.self, forKey: .isNillable)								// Required property
		self.isSortable = try container.decode(Bool.self, forKey: .isSortable)								// Required property
		self.isUpdateable = try container.decode(Bool.self, forKey: .isUpdateable)							// Required property
		self.label = try container.decode(String.self, forKey: .label)										// Required property
		self.length = try container.decodeIfPresent(UInt.self, forKey: .length)								// Optional property
		self.name = try container.decode(String.self, forKey: .name)										// Required property
		self.picklistValues = try container.decode([PicklistItem].self, forKey: .picklistValues)	// Required property
		self.relatedTypes = try container.decode([String].self, forKey: .relatedTypes)						// Required property
		self.relationshipName = try container.decodeIfPresent(String.self, forKey: .relationshipName)		// Optional property
		self.type = try container.decode(String.self, forKey: .type)										// Required property
	}
}

