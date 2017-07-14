//
//  Identity.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Holds result of call to identity URL
/// See: https://help.salesforce.com/HTViewHelpDoc?id=remoteaccess_using_openid.htm
public struct Identity {
	
	public let displayName: String
	public let language: String?
	public let lastModifiedDate: Date
	public let locale: String?
	public let mobilePhone: String?
	public let orgID: String
	public let photoURL: URL?
	public let profileURL: URL?
	public let recentRecordsURL: URL?
	public let thumbnailURL: URL?
	public let userID: String
	public let username: String
	public let userType: String
	
	public init(json: [String: Any]) throws {
		
		guard
			let displayName = json["display_name"] as? String,
			let lastModifiedDate = json.date(for: "last_modified_date"),
			let orgID = json["organization_id"] as? String,
			let userID = json["user_id"] as? String,
			let username = json["username"] as? String,
			let userType = json["user_type"] as? String else {
				
			throw SerializationError.invalid(json, message: "Unable to create Identity")
		}
	
		let photos = json["photos"] as? [String: String]
		let urls = json["urls"] as? [String: String]
	
		self.displayName = displayName
		self.language = json["language"] as? String
		self.lastModifiedDate = lastModifiedDate
		self.locale = json["locale"] as? String
		self.mobilePhone = json["mobile_phone"] as? String
		self.orgID = orgID
		self.photoURL = URL(string: photos?["picture"])
		self.profileURL = URL(string: urls?["profile"])
		self.recentRecordsURL = URL(string: urls?["recent"])
		self.thumbnailURL = URL(string: photos?["thumbnail"])
		self.userID = userID
		self.username = username
		self.userType = userType
	}
}
