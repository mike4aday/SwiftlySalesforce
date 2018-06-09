//
//  AuthorizationStore.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/20/18.
//

import Foundation

internal struct AuthorizationStore {
	
	internal struct Key {
		
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
	
	internal static func retrieve(for key: Key) -> Authorization? {
		guard let data = try? Keychain.read(service: key.keychainService, account: key.keychainAccount), let auth = try? JSONDecoder().decode(Authorization.self, from: data) else {
			return nil
		}
		return auth
	}
	
	internal static func store(_ authorization: Authorization, for key: Key) throws {
		let data = try JSONEncoder().encode(authorization)
		try Keychain.write(data: data, service: key.keychainService, account: key.keychainAccount)
	}
	
	internal static func clear(for key: Key) throws {
		do {
			try Keychain.delete(service: key.keychainService, account: key.keychainAccount)
		}
		catch(error: KeychainError.itemNotFound) {
			// Ignore
		}
	}
}
