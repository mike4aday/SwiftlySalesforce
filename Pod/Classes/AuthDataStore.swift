//
//  AuthDataStore.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Locksmith

internal final class AuthDataStore {

	internal static let shared = AuthDataStore()
	
	fileprivate init() {
		// Can't instantiate
	}
	
	internal func retrieve(username: String) -> AuthData? {
		guard let dict = Locksmith.loadDataForUserAccount(userAccount: username, inService: Constant.salesforce_service.rawValue) else {
			return nil
		}
		return AuthData(dictionary: dict)
	}
	
	internal func store(authData: AuthData, username: String) throws {
		try Locksmith.updateData(data: authData.toDictionary(), forUserAccount: username, inService: Constant.salesforce_service.rawValue)
	}
	
	internal func clear(username: String) throws {
		do {
			try Locksmith.deleteDataForUserAccount(userAccount: username, inService: Constant.salesforce_service.rawValue)
		}
		catch {
			// Ignore case of error if credentials aren't already in the keychain
			guard case LocksmithError.notFound = error else {
				throw error
			}
		}
	}
}

// MARK: - Constants
extension AuthDataStore {
	fileprivate enum Constant: String {
		case salesforce_service
	}
}
