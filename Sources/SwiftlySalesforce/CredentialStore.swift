//
//  CredentialStore.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

/// Secure storage of Salesforce access and refresh tokens
public struct CredentialStore {
    
    public let connectedApp: ConnectedApp
    
    internal let encoder = JSONEncoder()
    internal let decoder = JSONDecoder()
    internal let defaults = UserDefaults.standard
    
    internal var keychainService: String {
        return connectedApp.consumerKey
    }
    
    internal var lastStoredUserKey: String {
        return "\(connectedApp.consumerKey).LastStoredUser"
    }
    
    internal var lastStoredUser: User? {
        get {
            if let data = defaults.data(forKey: lastStoredUserKey), let user = try? decoder.decode(User.self, from: data) {
                return user
            }
            else {
                return nil
            }
        }
    }
    
    public init(for connectedApp: ConnectedApp) {
        self.connectedApp = connectedApp
    }
    
    public func retrieve(for user: User) -> Credential? {
        guard let data = try? Keychain.read(service: self.keychainService, account: user.keychainAccount),
            let auth = try? decoder.decode(Credential.self, from: data) else {
                return nil
        }
        return auth
    }
    
    public func store(_ credential: Credential) throws {
        let credData = try encoder.encode(credential)
        let user = User(userID: credential.userID, orgID: credential.orgID)
        try Keychain.write(data: credData, service: self.keychainService, account: user.keychainAccount)
        if let userData = try? encoder.encode(user) {
            defaults.set(userData, forKey: lastStoredUserKey)
        }
    }
    
    public func clear(for user: User) throws {
        defaults.removeObject(forKey: lastStoredUserKey)
        do {
            try Keychain.delete(service: self.keychainService, account: user.keychainAccount)
        }
        catch(error: KeychainError.itemNotFound) {
            // Ignore
        }
    }
    
    public func clear(credential: Credential) throws {
        let user = User(userID: credential.userID, orgID: credential.orgID)
        return try clear(for: user)
    }
}

fileprivate extension User {
    
    var keychainAccount: String {
        return "\(orgID):\(userID)"
    }
}
