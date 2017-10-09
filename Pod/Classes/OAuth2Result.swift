//
//  OAuth2Result.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Holds result of successful OAuth2 user-agent flow
/// See https://help.salesforce.com/articleView?id=remoteaccess_oauth_user_agent_flow.htm&type=0

internal struct OAuth2Result {
	
	internal let accessToken: String
	internal let refreshToken: String?
	internal let instanceURL: URL
	internal let identityURL: URL
	
	internal var userID: String {
		return identityURL.lastPathComponent
	}
	
	internal var orgID: String {
		return identityURL.deletingLastPathComponent().lastPathComponent
	}
	
	/// Initializer
	/// - Parameter accessToken: Salesforce access token (session ID).
	/// - Parameter instanceURL: Salesforce instance to use for subsequent, authenticated requests.
	/// - Parameter identityURL: Salesforce identity URL unique to the current user. See: https://help.salesforce.com/articleView?id=remoteaccess_using_openid.htm&type=0
	/// - Parameter refreshToken: Optional value for refresh token; since the refresh token flow doesn't return the refresh token itself,
	///   including the refresh token as an argument will preserve it for the next refresh request.
	internal init(accessToken: String, instanceURL: URL, identityURL: URL, refreshToken: String?) {
		self.accessToken = accessToken
		self.instanceURL = instanceURL
		self.identityURL = identityURL
		self.refreshToken = refreshToken
	}
	
	/// Initialize credentials from a Salesforce-produced redirect URL, to which
	/// URL-encoded token information has been appended in the fragment
	/// - Parameter urlEncodedString: URL fragment or query string as returned by Salesforce during OAuth2 user-agent or refresh token flow
	/// - Parameter refreshToken: Optional value for refresh token; since the refresh token flow doesn't return the refresh token itself,
	///   including the refresh token as an argument will preserve it for the next refresh request.
	internal init(urlEncodedString: String, refreshToken: String? = nil) throws {
		
		// Create 'fake' URL with argument as query string so we can use URL methods to access the embedded OAuth2 result
		guard let url = URL(string: "http://www.salesforce.com?\(urlEncodedString)"),
			let accessToken = url.value(forQueryItem: "access_token"),
			let instanceURL = URL(string: url.value(forQueryItem: "instance_url")),
			let identityURL = URL(string: url.value(forQueryItem: "id")) else {
			throw ApplicationError.invalidArgument(message: "Invalid URL-encoded string: \(urlEncodedString)")
		}
		
		let refreshToken = refreshToken ?? url.value(forQueryItem: "refresh_token")
		self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
	}
}

internal func ==(lhs: OAuth2Result, rhs: OAuth2Result) -> Bool {
	return lhs.accessToken == rhs.accessToken &&
		lhs.refreshToken == rhs.refreshToken &&
		lhs.instanceURL == rhs.instanceURL &&
		lhs.identityURL == rhs.identityURL
}
