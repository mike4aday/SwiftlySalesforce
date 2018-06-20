//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import SafariServices
import PromiseKit

public class Salesforce {
	
	public struct Configuration {
		public static let defaultVersion = "42.0"
		public static let defaultAuthorizationHost = "login.salesforce.com"
		public let consumerKey: String
		public let callbackURL: URL
		public let authorizationURL: URL
		public let version: String
	}
	
	public struct User {
		public let userID: String
		public let organizationID: String
	}
	
	public struct Options: OptionSet {
		public static let dontAuthenticate = Options(rawValue: 1 << 0)
		public let rawValue: Int
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
	public let configuration: Configuration
	
	public init(configuration: Configuration, user: User? = nil) {
		self.configuration = configuration
		if let u = user {
			authorizationStoreKey = AuthorizationStore.Key(userID: u.userID, organizationID: u.organizationID, consumerKey: configuration.consumerKey)
		}
		else {
			authorizationStoreKey = AuthorizationStore.lastStoredKey
		}
	}
	
	public convenience init(consumerKey: String, callbackURL: URL) throws {
		let config = try Configuration(consumerKey: consumerKey, callbackURL: callbackURL)
		self.init(configuration: config)
	}
	
	public var authorization: Authorization? {
		guard let key = self.authorizationStoreKey else {
			return nil
		}
		return AuthorizationStore.retrieve(for: key)
	}
	
	public var accessToken: String? {
		return authorization?.accessToken
	}
	
	internal var authorizationPromise: Promise<Authorization>?
	internal var authorizationStoreKey: AuthorizationStore.Key?
	internal var authenticationSession: SFAuthenticationSession?
}

public extension Salesforce.Configuration {
	
	public init(consumerKey: String,
				callbackURL: URL,
				authorizationHost: String = defaultAuthorizationHost,
				authorizationParameters: [String: String]? = nil,
				version: String = defaultVersion) throws {
		
		let defaultParams: [String: String] = [
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : callbackURL.absoluteString,
			"prompt" : "login consent",
			"display" : "touch" ]
		let params = defaultParams.merging(authorizationParameters ?? [:], uniquingKeysWith: { (_, new) in new })
		let urlString = "https://\(authorizationHost)/services/oauth2/authorize"
		guard let comps = URLComponents(string: urlString, parameters: params), let authorizationURL = comps.url else {
			let userInfo: [String: Any] = [NSURLErrorFailingURLErrorKey: urlString, NSLocalizedDescriptionKey: "Invalid authorization URL", "Parameters": params]
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: userInfo)
		}
		
		self.init(consumerKey: consumerKey, callbackURL: callbackURL, authorizationURL: authorizationURL, version: version)
	}
	
	public var oauthBaseURL: URL {
		var comps = URLComponents(url: authorizationURL.deletingLastPathComponent(), resolvingAgainstBaseURL: false)
		comps?.queryItems = nil
		return comps?.url ?? authorizationURL.deletingLastPathComponent()
	}
}
