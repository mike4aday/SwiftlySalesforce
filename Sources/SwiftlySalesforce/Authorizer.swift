import Foundation

public protocol Authorizer {
    func grantCredential(refreshing: Credential?) async throws -> Credential
    func revoke(credential: Credential) async throws -> ()
}
