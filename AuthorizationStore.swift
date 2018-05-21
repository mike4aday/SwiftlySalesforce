//
//  AuthorizationStore.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/20/18.
//

import Foundation

struct AuthorizationStore {
	
	struct User {
		
		let userID: String
		let organizationID: String
		let consumerKey: String
		
		fileprivate var keychainAccount: String {
			return "\(organizationID):\(userID)"
		}
		
		fileprivate var keychainService: String {
			return "SwiftlySalesforce.\(consumerKey)"
		}
	}
	
	static func retrieveAuthorization(for user: User) -> Authorization? {
		guard let data = try? Keychain.read(service: user.keychainService, account: user.keychainAccount),
			let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any],
			let accessToken = dict["access_token"] as? String,
			let instanceURLString = dict["instance_url"] as? String,
			let instanceURL = URL(string: instanceURLString),
			let identityURLString = dict["identity_url"] as? String,
			let identityURL = URL(string: identityURLString) else {
			return nil
		}
		return Authorization(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: dict["refresh_token"] as? String)
	}
	
	static func storeAuthorization(_ authorization: Authorization, for user: User) throws {
		var dict = [
			"access_token": authorization.accessToken,
			"instance_url": authorization.instanceURL.absoluteString,
			"identity_url": authorization.identityURL.absoluteString
		]
		if let refreshToken = authorization.refreshToken {
			dict["refresh_token"] = refreshToken
		}
		let data = NSKeyedArchiver.archivedData(withRootObject: dict)
		try Keychain.write(data: data, service: user.keychainService, account: user.keychainAccount)
	}
	
	static func clearAuthorization(for user: User) throws {
		do {
			try Keychain.delete(service: user.keychainService, account: user.keychainAccount)
		}
		catch(error: KeychainError.itemNotFound) {
			// Ignore
		}
	}
}
