//
//  OAuth2ResultStore.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import Locksmith

internal final class OAuth2ResultStore {
	
	internal struct Key {
		
		let userID: String
		let orgID: String
		let consumerKey: String
		
		var userAccount: String {
			return "\(orgID):\(userID)"
		}
		var service: String {
			return consumerKey
		}
	}
	
	static func retrieve(key: Key) -> OAuth2Result? {
		guard let d = Locksmith.loadDataForUserAccount(userAccount: key.userAccount, inService: key.service),
			let accessToken = d["access_token"] as? String,
			let instanceURL = URL(string: d["instance_url"] as? String),
			let identityURL = URL(string: d["identity_url"] as? String)	else {
			return nil
		}
		return OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: d["refresh_token"] as? String)
	}
	
	static func store(key: Key, value: OAuth2Result) throws {
		var data = [
			"access_token": value.accessToken,
			"instance_url": value.instanceURL.absoluteString,
			"identity_url": value.identityURL.absoluteString
		]
		if let refreshToken = value.refreshToken {
			data["refresh_token"] = refreshToken
		}
		try Locksmith.updateData(data: data, forUserAccount: key.userAccount, inService: key.service)
	}
	
	static func clear(key: Key) throws {
		do {
			try Locksmith.deleteDataForUserAccount(userAccount: key.userAccount, inService: key.service)
		}
		catch {
			// Ignore case of error if credentials aren't already in the keychain
			guard case LocksmithError.notFound = error else {
				throw error
			}
		}
	}
}
