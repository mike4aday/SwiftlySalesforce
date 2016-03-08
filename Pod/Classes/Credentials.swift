//
//  Credentials.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation


public struct Credentials: Equatable {

	
	public let accessToken: String
	public let refreshToken: String?
	public let instanceURL: NSURL
	public let identityURL: NSURL
	
	public var userID: String? {
		return identityURL.absoluteString.componentsSeparatedByString("/").last 
	}
	
	
	//
	// MARK: - Initializers
	//
	
	public init(accessToken: String, instanceURL: NSURL, identityURL: NSURL, refreshToken: String?) {
		self.accessToken = accessToken
		self.instanceURL = instanceURL
		self.identityURL = identityURL
		self.refreshToken = refreshToken
	}
	
	public init?(dictionary: [String: AnyObject]) {
		
		if	let accessToken = dictionary[Constant.access_token.rawValue] as? String,
			let instanceURL = dictionary[Constant.instance_url.rawValue] as? NSURL,
			let identityURL = dictionary[Constant.id.rawValue] as? NSURL {
				
			self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: dictionary[Constant.refresh_token.rawValue] as? String)
		}
		else {
			return nil
		}
	}
	
	/// Initialize credentials from a Salesforce-produced redirect URL, to which
	/// URL-encoded token information has been appended in the fragment
	/// - Parameter URLEncodedString: fragment or query string as returned by Salesforce during OAuth2 user-agent or refresh token flow
	/// - Parameter refreshToken: optional value for refresh token; since the refresh token flow doesn't return the refresh token itself, including it as an argument will preserve it for the next refresh request
	public init?(URLEncodedString: String, refreshToken: String? = nil) {
		
		// Create 'fake' URL with argument as query string
		guard let url = NSURL(string: "http://example.com?\(URLEncodedString)") else {
			return nil
		}
		
		guard let
			accessToken = url.valueForQueryItem(Constant.access_token.rawValue),
			instanceURL = NSURL(URLString: url.valueForQueryItem(Constant.instance_url.rawValue)),
			identityURL = NSURL(URLString: url.valueForQueryItem(Constant.id.rawValue)) else {
				
				return nil
		}
		
		let refreshToken = refreshToken ?? url.valueForQueryItem(Constant.refresh_token.rawValue)
		self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
	}
	
	
	// MARK: - Public methods
	
	/// Converts credentials struct to dictionary
	/// - Returns: Dictionary representation of credentials struct
	public func toDictionary() -> [String: AnyObject] {
		var dict = [
			Constant.access_token.rawValue : accessToken,
			Constant.instance_url.rawValue : instanceURL,
			Constant.id.rawValue : identityURL
		]
		if let refreshToken = self.refreshToken {
			dict[Constant.refresh_token.rawValue] = refreshToken
		}
		return dict
	}
}


// MARK: - Constants
extension Credentials {
	
	internal enum Constant: String {
		case access_token, instance_url, id, refresh_token
	}
}


// MARK: - Equality operator
public func ==(lhs: Credentials, rhs: Credentials) -> Bool {
	return lhs.accessToken == rhs.accessToken &&
		lhs.refreshToken == rhs.refreshToken &&
		lhs.instanceURL == rhs.instanceURL &&
		lhs.identityURL == rhs.identityURL
}