//
//  FieldDescription.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import Foundation

/// Salesforce field metadata
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm
public struct FieldDescription {
	
	public let defaultValue: Any?
	public let inlineHelpText: String?
	public let isCreateable: Bool
	public let isCustom: Bool
	public let isEncrypted: Bool
	public let isNillable: Bool
	public let isSortable: Bool
	public let isUpdateable: Bool
	public let label: String
	public let length: Int?
	public let name: String
	public let picklistValues: [PicklistItem]?
	public let relatedTypes: [String]?
	public let relationshipName: String?
	public let type: String
	
	public var helpText: String? {
		return inlineHelpText
	}

	init(json: [String: Any]) throws {
		
		guard
			let isCreateable = json["createable"] as? Bool,
			let isCustom = json["custom"] as? Bool,
			let isEncrypted = json["encrypted"] as? Bool,
			let isNillable = json["nillable"] as? Bool,
			let isSortable = json["sortable"] as? Bool,
			let isUpdateable = json["updateable"] as? Bool,
			let label = json["label"] as? String,
			let name = json["name"] as? String,
			let type = json["type"] as? String else {
				
				throw SerializationError.invalid(json, message: "Unable to create FieldDescription")
		}
		
		self.defaultValue = {
			if let val = json["defaultValue"], !(val is NSNull) {
				return val
			}
			else {
				return nil
			}
		}()
		self.inlineHelpText = json["inlineHelpText"] as? String
		self.isCreateable = isCreateable
		self.isCustom = isCustom
		self.isEncrypted = isEncrypted
		self.isNillable = isNillable
		self.isSortable = isSortable
		self.isUpdateable = isUpdateable
		self.label = label
		self.length = json["length"] as? Int
		self.name = name
		self.picklistValues = try (json["picklistValues"] as? [[String: Any]])?.map { try PicklistItem(json: $0) }
		
		/// If the field is a reference ("lookup") type, then 'relatedTypes' contains
		/// a list of object types to which the object may refer. Most standard
		/// lookup fields, and all custom lookup fields, may only refer to
		/// one type of object. Task.WhoId and Task.WhatId, for example, are
		/// polymorphic lookup fields and can refer to more than one type of object.
		self.relatedTypes = json["referenceTo"] as? [String]
		self.relationshipName = json["relationshipName"] as? String
		self.type = type
	}
}

