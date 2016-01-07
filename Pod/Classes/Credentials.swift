//
//  Credentials.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import Locksmith

public struct Credentials: Equatable {

	public let accessToken: String
	public let refreshToken: String?
	public let instanceURL: NSURL
	public let identityURL: NSURL
	
	public var userID: String {
		return identityURL.absoluteString.componentsSeparatedByString("/").last ?? "" // Should never be ""
	}
	
	public init(accessToken: String, instanceURL: NSURL, identityURL: NSURL, refreshToken: String?) {
		self.accessToken = accessToken
		self.instanceURL = instanceURL
		self.identityURL = identityURL
		self.refreshToken = refreshToken
	}
	
	public init?(dictionary: [String: AnyObject]) {
		if	let accessToken = dictionary["access_token"] as? String,
			let instanceURL = dictionary["instance_url"] as? NSURL,
			let identityURL = dictionary["id"] as? NSURL {
				
			self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: dictionary["refresh_token"] as? String)
		}
		else {
			return nil
		}
	}
	
	/// Initializer
	/// - Parameter callbackURL: URL with appended access token, instance URL, identity URL and optional refresh token
	public init?(callbackURL: NSURL) {
		
		if let modifiedURL = NSURL(string: callbackURL.absoluteString.stringByReplacingOccurrencesOfString("#", withString: "?")),
			let queryItems = NSURLComponents(string: modifiedURL.absoluteString)?.queryItems {
				
				var dict = [String: AnyObject]()
				for queryItem in queryItems {
					let key = queryItem.name.lowercaseString
					if let value = queryItem.value {
						switch key {
						case "access_token", "refresh_token":
							dict[key] = value
						case "instance_url", "id":
							if let url = NSURL(string: value) {
								dict[key] = url
							}
						default:
							continue
						}
					}
				}
				self.init(dictionary: dict)
		}
		else {
			return nil
		}
	}
	
	/// Initializer
	/// - Parameter json: JSON returned by Salesforce's OAuth2 "refresh token" flow
	/// - Parameter refreshToken: The current refresh token.
	public init?(json: AnyObject, refreshToken: String?) {
		if let jsonDict = json as? [String: String] {
			var dict = [String: AnyObject]()
			if let refreshToken = refreshToken {
				dict["refresh_token"] = refreshToken
			}
			for item in jsonDict {
				let (key, value) = (item.0.lowercaseString, item.1)
				switch key {
				case "access_token":
					dict[key] = value
				case "instance_url", "id":
					if let url = NSURL(string: value) {
						dict[key] = url
					}
				default:
					continue
				}
			}
			self.init(dictionary: dict)
		}
		else {
			return nil
		}
	}
	
	/// Converts credentials struct to dictionary
	/// - Returns: Dictionary representation of credentials struct
	public func toDictionary() -> [String: AnyObject] {
		var dict = [
			"access_token" : accessToken,
			"instance_url" : instanceURL,
			"id" : identityURL
		]
		if let refreshToken = self.refreshToken {
			dict["refresh_token"] = refreshToken
		}
		return dict
	}
}

public func ==(lhs: Credentials, rhs: Credentials) -> Bool {
	return lhs.accessToken == rhs.accessToken &&
		lhs.refreshToken == rhs.refreshToken &&
		lhs.instanceURL == rhs.instanceURL &&
		lhs.identityURL == rhs.identityURL
}