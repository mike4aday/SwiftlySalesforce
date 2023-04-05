import Foundation
import SwiftUI

/// Handles the interaction with the Salesforce REST API.
/// Your app should only have a single `Connection` instance.
public class Connection: ObservableObject {
    
    internal let authorizer: Authorizer
    internal let credentialStore: CredentialStore
    internal let defaults: UserDefaults
    internal let session: URLSession
    
    /// Unique identifier for current Salesforce user.
    public var userIdentifier: UserIdentifier? {
        get {
            return defaults.userIdentifier
        }
        set {
            DispatchQueue.main.async {
                self.defaults.userIdentifier = newValue
                self.objectWillChange.send()
            }
        }
    }
    
    public init(authorizer: Authorizer, credentialStore: CredentialStore, defaults: UserDefaults, session: URLSession = .shared) {
        self.authorizer = authorizer
        self.credentialStore = credentialStore
        self.defaults = defaults
        self.session = session
    }
    
    /// Makes an asynchronous request for data from the Salesforce REST API.
    /// - Parameters:
    ///   - service: The `DataService` instance from which you're requesting data
    /// - Returns: Output from the service endpoint
    public func request<T: DataService>(service: T) async throws -> T.Output {
        let credential = try await getCredential()
        do {
            return try await service.request(with: credential, using: session)
        }
        catch let error where error.isAuthenticationRequired {
            let newCredential = try await getCredential(refreshing: credential)
            return try await service.request(with: newCredential, using: session)
        }
    }
    
    public func getCredential(refreshing: Credential? = nil) async throws -> Credential {
        if let oldCredential = refreshing {
            return try await authenticate(refreshing: oldCredential)
        }
        else if let storedCredential = try await retrieveStoredCredential() {
            return storedCredential
        }
        else {
            return try await authenticate()
        }
    }
    
    public func retrieveStoredCredential() async throws -> Credential? {
        guard let id = userIdentifier, let cred = try await credentialStore.retrieve(for: id) else {
            return nil
        }
        return cred
    }
    
    public func authenticate(refreshing: Credential? = nil) async throws -> Credential {
        let cred = try await authorizer.grantCredential(refreshing: refreshing)
        try await credentialStore.save(credential: cred)
        self.userIdentifier = UserIdentifier(rawValue: cred.identityURL)
        return cred
    }
    
    public func logOut() async throws {
        defer { self.userIdentifier = nil }
        if let id = self.userIdentifier, let cred = try await credentialStore.retrieve(for: id) {
            Task { try? await authorizer.revoke(credential: cred) }
            Task { try? await credentialStore.delete(for: id) }
        }
    }
}
