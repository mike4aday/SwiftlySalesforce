import Foundation

/// Secure storage of Salesforce access and refresh tokens
struct DefaultCredentialStore {
    let consumerKey: String
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
}

extension DefaultCredentialStore: CredentialStore {
    
    func save(credential: Credential) throws {
        let data = try encoder.encode(credential)
        try Keychain.write(data: data, service: consumerKey, account: credential.identityURL.absoluteString)
    }
    
    func retrieve(for userIdentifier: URL) throws -> Credential? {
        do {
            let data = try Keychain.read(service: consumerKey, account: userIdentifier.absoluteString)
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
    
    func delete(for userIdentifier: URL) throws -> () {
        do {
            try Keychain.delete(service: consumerKey, account: userIdentifier.absoluteString)
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
