//
//  OAuth2ResultStore.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

internal final class OAuth2ResultStore {
	
	internal struct Key {
		
		let userID: String
		let orgID: String
		let consumerKey: String
		
		var account: String {
			return "\(orgID):\(userID)"
		}
		var service: String {
			return consumerKey
		}
	}
	
	static func retrieve(key: Key) -> OAuth2Result? {
		guard let data = try? Keychain.read(service: key.service, account: key.account),
			let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any],
			let accessToken = dict["access_token"] as? String,
			let instanceURL = URL(string: dict["instance_url"] as? String),
			let identityURL = URL(string: dict["identity_url"] as? String) else {
				return nil
		}
		return OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: dict["refresh_token"] as? String)
	}
	
	static func store(key: Key, value: OAuth2Result) throws {
		var dict = [
			"access_token": value.accessToken,
			"instance_url": value.instanceURL.absoluteString,
			"identity_url": value.identityURL.absoluteString
		]
		if let refreshToken = value.refreshToken {
			dict["refresh_token"] = refreshToken
		}
		let data = NSKeyedArchiver.archivedData(withRootObject: dict)
		try Keychain.write(data: data, service: key.service, account: key.account)
	}
	
	static func clear(key: Key) throws {
		do {
			try Keychain.delete(service: key.service, account: key.account)
		}
		catch(error: KeychainError.itemNotFound) {
			// Ignore
		}
	}
}
