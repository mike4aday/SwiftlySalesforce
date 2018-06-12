//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import SafariServices

public class Salesforce {
	
	public typealias User = (userID: String, organizationID: String)
	
	public let configuration: Configuration
	
	internal var authorizationPromise: Promise<Authorization>?
	internal var authorizationSession: SFAuthenticationSession?
	internal var authorizationStoreKey: AuthorizationStore.Key?
	
	public init(configuration: Configuration, user: User? = nil) {
		self.configuration = configuration
		if let u = user {
			authorizationStoreKey = AuthorizationStore.Key(userID: u.userID, organizationID: u.organizationID, consumerKey: configuration.consumerKey)
		}
		else {
			authorizationStoreKey = AuthorizationStore.lastStoredKey
		}
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
	
	public var version: String {
		return configuration.version
	}
}
