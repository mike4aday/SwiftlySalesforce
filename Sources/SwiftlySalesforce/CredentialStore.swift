import Foundation

public protocol CredentialStore {
    func save(credential: Credential) async throws -> ()
    func retrieve(for userIdentifier: URL) async throws -> Credential?
    func delete(for userIdentifier: URL) async throws -> ()
}
