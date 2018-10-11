//
//  Identity.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
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
	public let thumbnailURL: URL?
	public let userID: String	// ID of the user record
	public let username: String	// Salesforce username, in email format
	public let userType: String
}

extension Identity: Decodable {
	
	enum CodingKeys: String, CodingKey {
		
		case displayName = "display_name"
		case language
		case lastModifiedDate = "last_modified_date"
		case locale
		case mobilePhone = "mobile_phone"
		case orgID = "organization_id"
		case userID = "user_id"
		case username
		case userType = "user_type"
		
		// Nested container keys
		case photos
		case urls
	}
	
	enum PhotoKeys: String, CodingKey {
		case picture
		case thumbnail
	}
	
	enum URLKeys: String, CodingKey {
		case profile
	}
	
	public init(from decoder: Decoder) throws {
		
		// Top level container
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// Nested containers
		let photos = try container.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photos)
		let urls = try container.nestedContainer(keyedBy: URLKeys.self, forKey: .urls)
		
		// Set properties
		self.displayName = try container.decode(String.self, forKey: .displayName)
		self.language = try container.decodeIfPresent(String.self, forKey: .language)
		self.lastModifiedDate = try {
			// In Winter '19, date format changed for this field so we need to try both
			// formats until Winter '19 is deployed in all orgs, then only new format.
			// See: https://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/rn_security_auth_json_value_endpoints.htm
			//TODO: more comprehensive solution that could handle all formats in decoder?
			if let date = try? container.decode(Date.self, forKey: .lastModifiedDate) {
				return date
			}
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [.withInternetDateTime]
			guard let string = try? container.decode(String.self, forKey: .lastModifiedDate), let date = formatter.date(from: string) else {
				throw DecodingError.dataCorruptedError(forKey: .lastModifiedDate, in: container, debugDescription: "Unable to decode last modified date.")
			}
			return date
		}()
		self.locale = try container.decodeIfPresent(String.self, forKey: .locale)
		self.mobilePhone = try container.decodeIfPresent(String.self, forKey: .mobilePhone)
		self.orgID = try container.decode(String.self, forKey: .orgID)
		self.photoURL = try photos.decodeIfPresent(URL.self, forKey: .picture)
		self.profileURL = try urls.decodeIfPresent(URL.self, forKey: .profile)
		self.thumbnailURL = try photos.decodeIfPresent(URL.self, forKey: .thumbnail)
		self.userID = try container.decode(String.self, forKey: .userID)
		self.username = try container.decode(String.self, forKey: .username)
		self.userType = try container.decode(String.self, forKey: .userType)
	}
}
