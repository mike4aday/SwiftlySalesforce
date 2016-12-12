//
//  Model.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

/// Holds the result of a SOQL query
/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
public struct QueryResult {
	
	public let totalSize: Int
	public let isDone: Bool
	public let records: [[String: Any]]
	public let nextRecordsPath: String?
	
	init(json: [String: Any]) throws {
		guard let totalSize = json["totalSize"] as? Int, let isDone = json["done"] as? Bool, let records = json["records"] as? [[String: Any]] else {
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
	
	public init(name: String, maximum: Int, remaining: Int) {
		self.name = name
		self.maximum = maximum
		self.remaining = remaining
	}
}

/// Holds result of call to identity URL
/// See: https://help.salesforce.com/HTViewHelpDoc?id=remoteaccess_using_openid.htm
public struct UserInfo {
	
	public let dictionary: [String: Any]
	
	public var displayName: String? {
		return dictionary["display_name"] as? String
	}
	
	public var mobilePhone: String? {
		return dictionary["mobile_phone"] as? String
	}
	
	public var username: String? {
		return dictionary["username"] as? String
	}
	
	public var userID: String? {
		return dictionary["user_id"] as? String
	}
	
	public var orgID: String? {
		return dictionary["organization_id"] as? String
	}
	
	public var userType: String? {
		return dictionary["user_type"] as? String
	}
	
	public var language: String? {
		return dictionary["language"] as? String
	}
	
	public var lastModifiedDate: Date? {
		return dictionary.dateValue(forKey: "last_modified_date")
	}
	
	public var locale: String? {
		return dictionary["locale"] as? String
	}
	
	public var photoURL: URL? {
		guard let photos = dictionary["photos"] as? [String: String], let photoURL = URL(string: photos["picture"]) else {
			return nil
		}
		return photoURL
	}
	
	public var thumbnailURL: URL? {
		guard let photos = dictionary["photos"] as? [String: String], let thumbnailURL = URL(string: photos["thumbnail"]) else {
			return nil
		}
		return thumbnailURL
	}
	
	public var profileURL: URL? {
		guard let urls = dictionary["urls"] as? [String: String], let profileURL = URL(string: urls["profile"]) else {
			return nil
		}
		return profileURL
	}
	
	public var recentRecordsURL: URL? {
		guard let urls = dictionary["urls"] as? [String: String], let recentRecordsURL = URL(string: urls["recent"]) else {
			return nil
		}
		return recentRecordsURL
	}
	
	/// Initializer
	init(json: [String: Any]) {
		self.dictionary = json
	}
}
