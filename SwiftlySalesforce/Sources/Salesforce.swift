//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation
import SafariServices
import PromiseKit

public class Salesforce {
	
	public struct Configuration {
		public static let defaultVersion = "44.0"
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
		public static let dontAuthenticate = Options(rawValue: 1 << 0) // Set this in functions to defer login
		public let rawValue: Int
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
	public let configuration: Configuration
	internal var authorizationPromise: Promise<Authorization>?
	internal var authorizationStoreKey: AuthorizationStore.Key?
	internal var authenticationSession: SFAuthenticationSession?
	
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
	
	public var refreshToken: String? {
		return authorization?.refreshToken
	}
	
	public var instanceURL: URL? {
		return authorization?.instanceURL
	}
	
	public var userID: String? {
		return authorization?.userID
	}
	
	public var orgID: String? {
		return authorization?.orgID
	}
	
	public var config: Configuration {
		return configuration
	}
}
