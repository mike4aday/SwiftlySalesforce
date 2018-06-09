//
//  Salesforce+Configuration.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import PromiseKit

public extension Salesforce {
	
	public struct Configuration {
		
		static public let defaultVersion = "42.0"
		
		public let consumerKey: String
		public let callbackURL: URL
		public let version: String
		public let authorizationURL: URL
		
		public init(consumerKey: String, callbackURL: URL, version: String, authorizationURL: URL) {
			self.consumerKey = consumerKey
			self.callbackURL = callbackURL
			self.version = version
			self.authorizationURL = authorizationURL
		}
		
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
			
			self.init(consumerKey: consumerKey, callbackURL: callbackURL, version: version, authorizationURL: authorizationURL)
		}
	}
}
