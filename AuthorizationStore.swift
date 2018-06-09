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
			let auth = NSKeyedUnarchiver.unarchiveObject(with: data) as? Authorization else {
			return nil
		}
		return auth
	}
	
	static func storeAuthorization(_ authorization: Authorization, for user: User) throws {
		let data = NSKeyedArchiver.archivedData(withRootObject: authorization)
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
