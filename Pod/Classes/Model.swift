//
//  Model.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

public protocol JSONBacking {
	var json: [String: Any] { get }
}

/// Holds the result of a SOQL query
/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
public struct QueryResult {
	
	public let totalSize: Int
	public let isDone: Bool
	public let records: [[String: Any]]
	public let nextRecordsPath: String?
	
	init(json: [String: Any]) throws {
		guard
			let totalSize = json["totalSize"] as? Int,
			let isDone = json["done"] as? Bool,
			let records = json["records"] as? [[String: Any]] else {
			throw SalesforceError.jsonDeserializationFailure(elementName: nil, json: json)
		}
		self.totalSize = totalSize
		self.isDone = isDone
		self.records = records
		self.nextRecordsPath = json["nextRecordsUrl"] as? String
		if !isDone && self.nextRecordsPath == nil {
			throw SalesforceError.invalidity(message: "Missing next records path for query result!")
		}
	}
}

/// Represents a limited Salesforce resource
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
public struct Limit {
	
	public let name: String
	public let maximum: Int
	public let remaining: Int
	
	public init(name: String, json: [String: Int]) throws {
		guard let remaining = json["Remaining"], let maximum = json["Max"] else {
			throw SalesforceError.jsonDeserializationFailure(elementName: name, json: json)
		}
		self.name = name
		self.maximum = maximum
		self.remaining = remaining
	}
}

/// Holds result of call to identity URL
/// See: https://help.salesforce.com/HTViewHelpDoc?id=remoteaccess_using_openid.htm
public struct UserInfo: JSONBacking {
	
	public let json: [String: Any]
	
	public var displayName: String? {
		return json["display_name"] as? String
	}
	
	public var mobilePhone: String? {
		return json["mobile_phone"] as? String
	}
	
	public var username: String? {
		return json["username"] as? String
	}
	
	public var userID: String? {
		return json["user_id"] as? String
	}
	
	public var orgID: String? {
		return json["organization_id"] as? String
	}
	
	public var userType: String? {
		return json["user_type"] as? String
	}
	
	public var language: String? {
		return json["language"] as? String
	}
	
	public var lastModifiedDate: Date? {
		return json.dateValue(forKey: "last_modified_date")
	}
	
	public var locale: String? {
		return json["locale"] as? String
	}
	
	public var photoURL: URL? {
		guard let photos = json["photos"] as? [String: String], let photoURL = URL(string: photos["picture"]) else {
			return nil
		}
		return photoURL
	}
	
	public var thumbnailURL: URL? {
		guard let photos = json["photos"] as? [String: String], let thumbnailURL = URL(string: photos["thumbnail"]) else {
			return nil
		}
		return thumbnailURL
	}
	
	public var profileURL: URL? {
		guard let urls = json["urls"] as? [String: String], let profileURL = URL(string: urls["profile"]) else {
			return nil
		}
		return profileURL
	}
	
	public var recentRecordsURL: URL? {
		guard let urls = json["urls"] as? [String: String], let recentRecordsURL = URL(string: urls["recent"]) else {
			return nil
		}
		return recentRecordsURL
	}
	
	/// Initializer
	init(json: [String: Any]) {
		self.json = json
	}
}

/// Salesforce object metadata
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm
public struct ObjectDescription: JSONBacking {
	
	public let json: [String : Any]
	
	public var fields: [String: FieldDescription] {
		let jsons = json["fields"] as! [[String: Any]]
		let fields = jsons.asDictionary {
			(json) -> [String: FieldDescription] in
			let field = FieldDescription(json: json)
			return [field.name: field]
		}
		return fields
	}
	
	public var isCreateable: Bool {
		return json["createable"] as! Bool
	}
	
	/// If true, this is a custom object
	public var isCustom: Bool {
		return json["custom"] as! Bool
	}
	
	/// If true, this is a custom setting.
	/// See: https://help.salesforce.com/articleView?id=cs_about.htm
	public var isCustomSetting: Bool {
		return json["customSetting"] as! Bool
	}
	
	public var isDeletable:Bool {
		return json["deletable"] as! Bool
	}
	
	/// If true, Chatter feeds are enabled for this object.
	public var isFeedEnabled: Bool {
		return json["feedEnabled"] as! Bool
	}
	
	/// If true, this object's records may be queried
	public var isQueryable: Bool {
		return json["queryable"] as! Bool
	}
	
	/// If true, this object's records may be searched
	public var isSearchable: Bool {
		return json["searchable"] as! Bool
	}
	
	/// If true, this object's records may have database triggers "attached" to them
	public var isTriggerable: Bool {
		return json["triggerable"] as! Bool
	}
	
	/// If true, this object's records may be undeleted (i.e. restored from trash)
	public var isUndeletable: Bool {
		return json["undeletable"] as! Bool
	}
	
	/// If true, this object's records may be updated
	public var isUpdateable: Bool {
		return json["updateable"] as! Bool
	}
	
	/// The first 3 characters of this object's record IDs
	public var keyPrefix: String {
		return json["keyPrefix"] as! String
	}
	
	public var label: String {
		return json["label"] as! String
	}
	
	/// Synonym for pluralLabel
	public var labelPlural: String {
		return pluralLabel
	}
	
	public var name: String {
		return json["name"] as! String
	}
	
	public var pluralLabel: String {
		return json["labelPlural"] as! String
	}
	
	public init(json: [String: Any]) {
		self.json = json
	}
}

/// Salesforce field metadata 
/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm
public struct FieldDescription: JSONBacking {
	
	public let json: [String: Any]
	
	/// This field's default value, if any
	public var defaultValue: Any? {
		// Deserialized JSON is stored in an NSDictionary, which may have NSNull instead of nil values
		guard let val = json["defaultValue"], !(val is NSNull) else {
			return nil
		}
		return val
	}
	
	/// The inline help text assigned to this field
	public var helpText: String? {
		return json["inlineHelpText"] as? String
	}
	
	/// Synonym for helpText
	public var inlineHelpText: String? {
		return helpText
	}
	
	public var isCreateable: Bool {
		return json["createable"] as! Bool
	}
	
	/// If true, this is a custom field
	public var isCustom: Bool {
		return json["custom"] as! Bool
	}
	
	public var isEncrypted: Bool {
		return json["encrypted"] as! Bool 
	}
	
	/// If true, the value of this field may be set to NULL in Salesforce
	public var isNillable: Bool {
		return json["nillable"] as! Bool
	}
	
	public var isSortable: Bool {
		return json["sortable"] as! Bool
	}
	
	/// If true, the value of this field may be updated
	public var isUpdateable: Bool {
		return json["updateable"] as! Bool
	}
	
	public var label: String {
		return json["label"] as! String
	}
	
	public var length: Int {
		return json["length"] as! Int
	}
	
	public var name: String {
		return json["name"] as! String
	}
	
	public var picklistValues: [PicklistValue] {
		let jsons = json["picklistValues"] as! [[String: Any]]
		return jsons.map { PicklistValue(json: $0) }
	}
	
	/// If the field is a reference ("lookup") type, then this property contains
	/// a list of object types to which the object may refer. Most standard
	/// lookup fields, and all custom lookup fields, may only refer to
	/// one type of object. Task.WhoId and Task.WhatId, for example, are
	/// polymorphic lookup fields and can refer to more than one type of object.
	public var relatedTypes: [String] {
		return json["referenceTo"] as! [String]
	}
	
	/// Synonym for relatedTypes
	public var referenceTo: [String] {
		return relatedTypes
	}
	
	/// See: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_relationships_understanding.htm
	public var relationshipName: String? {
		return json["relationshipName"] as? String
	}
	
	public var type: String {
		return json["type"] as! String
	}
	
	public init(json: [String: Any]) {
		self.json = json
	}
}

/// Represents options in a Salesforce Picklist-type field (i.e. drop-down list)
public struct PicklistValue {
	
	public let isActive: Bool
	public let isDefault: Bool
	public let label: String
	public let value: String
	
	public init(json: [String: Any]) {
		isActive = json["active"] as! Bool
		isDefault = json["defaultValue"] as! Bool
		label = json["label"] as! String
		value = json["value"] as! String
	}
}
