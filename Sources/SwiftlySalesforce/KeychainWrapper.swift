/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

/// Adapted from https://forums.developer.apple.com/thread/86961
internal struct KeychainWrapper {
    
    /// Returns the value of a generic password keychain item.
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    /// - Returns: The value of the item
    /// - Throws: Any error returned by the Security framework.
    static func read(service: String, account: String) throws -> Data {
        var copyResult: CFTypeRef? = nil
        let err = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
            ] as NSDictionary, &copyResult)
        switch err {
        case errSecSuccess:
            return copyResult as? Data ?? Data()
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.readFailure(status: err)
        }
    }
    
    /// Stores a value to a generic password keychain item.
    /// This method delegates the work to two helper routines depending on whether the item already
    /// exists in the keychain or not.
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    ///   - data: The desired data.
    /// - Throws: Any error returned by the Security framework.
    static func write(data password: Data, service: String, account: String) throws {
        var copyResult: CFTypeRef? = nil
        let err = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
            ] as NSDictionary, &copyResult)
        switch err {
        case errSecSuccess:
            let oldPassword = copyResult as? Data ?? Data()
            if oldPassword != password {
                try self.storeByUpdating(service: service, account: account, password: password)
            }
        case errSecItemNotFound:
            try self.storeByAdding(service: service, account: account, password: password)
        default:
            throw KeychainError.writeFailure(status: err)
        }
    }
    
    /// Deletes an item from the keychain.
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    static func delete(service: String, account: String) throws {
        
        // Delete the existing item from the keychain.
        let err = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            ] as NSDictionary)
        
        // Throw an error if an unexpected status was returned
        switch err {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.deleteFailure(status: err)
        }
    }
    
    /// Stores a value to a generic password keychain item.
    /// This private routine is called to update an existing keychain item.
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    ///   - password: The desired password.
    /// - Throws: Any error returned by the Security framework.
    private static func storeByUpdating(service: String, account: String, password: Data) throws {
        let err = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            ] as NSDictionary, [
                kSecValueData: password
                ] as NSDictionary)
        guard err == errSecSuccess else {
            throw KeychainError.writeFailure(status: err)
        }
    }
    
    /// Stores a value to a generic password keychain item.
    /// This private routine is called to add the keychain item.
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    ///   - password: The desired password.
    /// - Throws: Any error returned by the Security framework.
    private static func storeByAdding(service: String, account: String, password: Data) throws {
        let err = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: password,
            ] as NSDictionary, nil)
        guard err == errSecSuccess else {
            throw KeychainError.writeFailure(status: err)
        }
    }
}

internal enum KeychainError: Error, Equatable {
    case readFailure(status: OSStatus)
    case writeFailure(status: OSStatus)
    case deleteFailure(status: OSStatus)
    case itemNotFound
}
