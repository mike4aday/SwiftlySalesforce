//
//  AuthData.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

public struct AuthData: Equatable {
	
	//
	// MARK: - Variables
	//
	
	public let accessToken: String
	public let refreshToken: String?
	public let instanceURL: URL
	public let identityURL: URL
	
	public var userID: String? {
		return identityURL.absoluteString.components(separatedBy: "/").last
	}
	
	//
	// MARK: - Initializers
	//
	
	public init(accessToken: String, instanceURL: URL, identityURL: URL, refreshToken: String?) {
		self.accessToken = accessToken
		self.instanceURL = instanceURL
		self.identityURL = identityURL
		self.refreshToken = refreshToken
	}
	
	public init?(dictionary: [String: Any]) {
		if	let accessToken = dictionary[Constant.access_token.rawValue] as? String,
			let instanceURL = dictionary[Constant.instance_url.rawValue] as? URL,
			let identityURL = dictionary[Constant.id.rawValue] as? URL {
			self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: dictionary[Constant.refresh_token.rawValue] as? String)
		}
		else {
			return nil
		}
	}
	
	/// Initialize credentials from a Salesforce-produced redirect URL, to which
	/// URL-encoded token information has been appended in the fragment
	/// - Parameter urlEncodedString: Fragment or query string as returned by Salesforce during OAuth2 user-agent or refresh token flow
	/// - Parameter refreshToken: Optional value for refresh token; since the refresh token flow doesn't return the refresh token itself, including it as an argument will preserve it for the next refresh request
	public init?(urlEncodedString: String, refreshToken: String? = nil) {
		
		// Create 'fake' URL with argument as query string
		guard let url = URL(string: "http://example.com?\(urlEncodedString)") else {
			return nil
		}
		
		guard let accessToken = url.value(forQueryItem: Constant.access_token.rawValue),
			let instanceURL = URL(string: url.value(forQueryItem: Constant.instance_url.rawValue)),
			let identityURL = URL(string: url.value(forQueryItem: Constant.id.rawValue)) else {
			return nil
		}
		
		let refreshToken = refreshToken ?? url.value(forQueryItem: Constant.refresh_token.rawValue)
		self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
	}
	
	// MARK: - Public methods
	
	/// Converts credentials struct to dictionary
	/// - Returns: Dictionary representation of credentials struct
	public func toDictionary() -> [String: Any] {
		var dict: [String: Any] = [
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
extension AuthData {
	fileprivate enum Constant: String {
		case access_token, instance_url, id, refresh_token
	}
}

// MARK: - Equality operator
public func ==(lhs: AuthData, rhs: AuthData) -> Bool {
	return lhs.accessToken == rhs.accessToken &&
		lhs.refreshToken == rhs.refreshToken &&
		lhs.instanceURL == rhs.instanceURL &&
		lhs.identityURL == rhs.identityURL
}
