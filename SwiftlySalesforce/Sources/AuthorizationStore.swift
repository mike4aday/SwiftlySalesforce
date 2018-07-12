//
//  AuthorizationStore.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal struct AuthorizationStore {
	
	internal struct Key: Codable {
		
		let userID: String
		let organizationID: String
		let consumerKey: String
		
		fileprivate var keychainAccount: String {
			return "\(organizationID):\(userID)"
		}
		
		fileprivate var keychainService: String {
			return consumerKey
		}
	}
	
	internal static let encoder = JSONEncoder()
	internal static let decoder = JSONDecoder()
	internal static let defaults = UserDefaults()
	
	internal static var lastStoredKey: Key? {
		get {
			if let data = defaults.data(forKey: "LastStoredKey"), let key = try? decoder.decode(Key.self, from: data) {
				return key
			}
			else {
				return nil
			}
		}
		set {
			if let key = newValue, let data = try? encoder.encode(key) {
				defaults.set(data, forKey: "LastStoredKey")
			}
			else {
				defaults.removeObject(forKey: "LastStoredKey")
			}
		}
	}
	
	internal static func retrieve(for key: Key) -> Authorization? {
		guard let data = try? Keychain.read(service: key.keychainService, account: key.keychainAccount),
			let auth = try? decoder.decode(Authorization.self, from: data) else {
				return nil
		}
		return auth
	}
	
	internal static func store(_ authorization: Authorization, for key: Key) throws {
		let data = try encoder.encode(authorization)
		try Keychain.write(data: data, service: key.keychainService, account: key.keychainAccount)
		lastStoredKey = key
	}
	
	internal static func clear(for key: Key) throws {
		do {
			try Keychain.delete(service: key.keychainService, account: key.keychainAccount)
		}
		catch(error: Keychain.Error.itemNotFound) {
			// Ignore
		}
	}
}
