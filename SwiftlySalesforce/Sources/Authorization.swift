//
//  Authorization.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

/// Holds result of successful OAuth2 user-agent flow
/// See https://help.salesforce.com/articleView?id=remoteaccess_oauth_user_agent_flow.htm

public struct Authorization: Codable, Equatable {
	public let accessToken: String
	public let instanceURL: URL
	public let identityURL: URL
	public let refreshToken: String?
	public let issuedAt: UInt?
}

public extension Authorization {
	
	public var userID: String {
		return identityURL.lastPathComponent
	}
	
	public var orgID: String {
		return identityURL.deletingLastPathComponent().lastPathComponent
	}
}

internal extension Authorization {
	
	init(with url: URL) throws {
		
		// Salesforce returns authorization result in the redirect URL's fragment
		// so let's make it a query string instead so we can parse with URLComponents
		guard
			let modifiedURL = URL(string: url.absoluteString.replacingOccurrences(of: "#", with: "?")),
			let queryItems = URLComponents(url: modifiedURL, resolvingAgainstBaseURL: false)?.queryItems,
			let accessToken = queryItems.filter({$0.name == "access_token"}).first?.value,
			let instanceURLString = queryItems.filter({$0.name == "instance_url"}).first?.value,
			let instanceURL = URL(string: instanceURLString),
			let identityURLString = queryItems.filter({$0.name == "id"}).first?.value,
			let identityURL = URL(string: identityURLString),
			let issuedAtString = queryItems.filter({$0.name == "issued_at"}).first?.value,
			let issuedAt = UInt(issuedAtString)
		else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLStringErrorKey: url])
		}
		
		// Parse refresh token if it's provided in the redirect URL, per defined 'scopes' of Connected App
		let refreshToken: String? = queryItems.filter({ $0.name == "refresh_token" }).first?.value
		
		self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken, issuedAt: issuedAt)
	}
}
