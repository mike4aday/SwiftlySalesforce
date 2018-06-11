//
//  Configuration.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/9/18.
//

import Foundation

public struct Configuration {
	
	static public let defaultVersion = "42.0"
	
	public let consumerKey: String
	public let callbackURL: URL
	public let authorizationURL: URL
	public let version: String
}

extension Configuration {
	
	public init(consumerKey: String, callbackURL: URL, authorizationHost: String = "login.salesforce.com", version: String = Configuration.defaultVersion) throws {
		
		// Build authorization URL
		let params: [String: String] = [
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : callbackURL.absoluteString,
			"prompt" : "login consent",
			"display" : "touch" ]
		let urlString = "https://\(authorizationHost)/services/oauth2/authorize"
		guard let comps = URLComponents(string: urlString, parameters: params), let authorizationURL = comps.url else {
			let userInfo: [String: Any] = [NSURLErrorFailingURLErrorKey: urlString, NSLocalizedDescriptionKey: "Invalid authorization URL", "Parameters": params]
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: userInfo)
		}
		
		self.init(consumerKey: consumerKey, callbackURL: callbackURL, authorizationURL: authorizationURL, version: version)
	}
}
