import Foundation

public protocol CredentialStore {
    func save(credential: Credential) async throws -> ()
    func retrieve(for userIdentifier: UserIdentifier) async throws -> Credential?
    func delete(for userIdentifier: UserIdentifier) async throws -> ()
}
