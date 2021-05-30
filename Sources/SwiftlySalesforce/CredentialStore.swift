/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

/// Secure storage of Salesforce access and refresh tokens
struct CredentialStore {
    var consumerKey: String
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
}

extension CredentialStore {
    
    func store(_ credential: Credential) throws {
        let data = try encoder.encode(credential)
        let user = credential.user
        try KeychainWrapper.write(data: data, service: consumerKey, account: String(describing: user))
    }
    
    func retrieve(for user: UserIdentifier) throws -> Credential? {
        do {
            let data = try KeychainWrapper.read(service: consumerKey, account: String(describing: user))
            return try decoder.decode(Credential.self, from: data)
        }
        catch {
            if case KeychainError.itemNotFound = error {
                return nil
            }
            else {
                throw error
            }
        }
    }
    
    func delete(for user: UserIdentifier) throws -> () {
        do {
            try KeychainWrapper.delete(service: consumerKey, account: String(describing: user))
        }
        catch {
            if case KeychainError.itemNotFound = error {
                return
            }
            else {
                throw error
            }
        }
    }
}
