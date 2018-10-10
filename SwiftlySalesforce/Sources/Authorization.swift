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
	public let idToken: String?
	public let communityURL: URL?
	public let communityID: String?
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
	
	init(with redirectURL: URL) throws {
		
		// Salesforce returns authorization result in the redirect URL's fragment
		// so let's make it a query string instead so we can parse with URLComponents
		guard let url = URL(string: redirectURL.absoluteString.replacingOccurrences(of: "#", with: "?")),
			let accessToken = url.queryItems(named: "access_token")?.first?.value,
			let instanceURL = URL(string: url.queryItems(named: "instance_url")?.first?.value ?? ""),
			let identityURL = URL(string: url.queryItems(named: "id")?.first?.value ?? ""),
			let issuedAtString = url.queryItems(named: "issued_at")?.first?.value,
			let issuedAt = UInt(issuedAtString) else {
				throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLStringErrorKey: redirectURL])
		}
		
		// Parse values which *may* be present in the redirect URL, depending on configuration
		let refreshToken: String? = url.queryItems(named: "refresh_token")?.first?.value
		let idToken: String? = url.queryItems(named: "id_token")?.first?.value
		let communityID: String? = url.queryItems(named: "sfdc_community_id")?.first?.value
		let communityURL: URL? = URL(string: url.queryItems(named: "sfdc_community_url")?.first?.value ?? "")
		
		self.init(accessToken: accessToken,
				  instanceURL: instanceURL,
				  identityURL: identityURL,
				  refreshToken: refreshToken,
				  issuedAt: issuedAt,
				  idToken: idToken,
				  communityURL: communityURL,
				  communityID: communityID)
	}
	
	/// Creates a new Authorization instance with values returned during OAuth 2.0 refresh token flow
	/// See: https://help.salesforce.com/articleView?id=remoteaccess_oauth_refresh_token_flow.htm&type=5
	func refreshedWith(result: RefreshTokenResult) -> Authorization {
		return Authorization(accessToken: result.accessToken,
							 instanceURL: result.instanceURL,
							 identityURL: result.identityURL,
							 refreshToken: self.refreshToken,
							 issuedAt: result.issuedAt,
							 idToken: self.idToken,
							 communityURL: result.communityURL,
							 communityID: result.communityID)
	}
}

public extension Authorization {
	
	/// Initializer. New properties were added to the Authorization struct for v.7.1,
	/// so in order not to break any existing developer code, this initializer was added, too.
	@available(*, deprecated, message: "Use default initializer instead.")
	init(accessToken: String, instanceURL: URL, identityURL: URL, refreshToken: String?, issuedAt: UInt?) {
		self.init(accessToken: accessToken,
				  instanceURL: instanceURL,
				  identityURL: identityURL,
				  refreshToken: refreshToken,
				  issuedAt: issuedAt,
				  idToken: nil,
				  communityURL: nil,
				  communityID: nil)
	}
}
