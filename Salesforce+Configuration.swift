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
		
		private static let defaultAuthorizationHost = "login.salesforce.com"
		private static let defaultVersion = "42.0"
		
		public let consumerKey: String
		public let callbackURL: URL
		public let authorizationHost: String
		public let version: String
		public let authorizationParameters: [String: String]?
		
		public init(
			consumerKey: String,
			callbackURL: URL,
			authorizationHost: String = Configuration.defaultAuthorizationHost,
			version: String = Configuration.defaultVersion,
			authorizationParameters: [String: String]? = nil) {
			
			self.consumerKey = consumerKey
			self.callbackURL = callbackURL
			self.authorizationHost = authorizationHost
			self.version = version
			self.authorizationParameters = authorizationParameters
		}
		
		internal func authorizationURL() throws -> URL {
			
			var params: [String: String] = [
				"response_type" : "token",
				"client_id" : consumerKey,
				"redirect_uri" : callbackURL.absoluteString,
				"prompt" : "login consent",
				"display" : "touch" ]
			
			if let additionalParams = authorizationParameters {
				for (key,value) in additionalParams {
					params[key] = value
				}
			}
			
			let urlString = "https://\(authorizationHost)/services/oauth2/authorize"
			guard let comps = URLComponents(string: urlString, parameters: params), let url = comps.url else {
				let userInfo: [String: Any] = [NSURLErrorFailingURLErrorKey: urlString, NSLocalizedDescriptionKey: "Invalid authorization URL", "Parameters": params]
				throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: userInfo)
			}
			
			return url
		}
	}
}
