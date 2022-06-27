import Foundation

public struct UserIdentifier {
    
    let identityURL: URL
    
    /// The ID of the Salesforce User record associated with this credential.
    var userID: String {
        return identityURL.lastPathComponent
    }
    
    /// The ID of the Salesforce Organization record associated with this credential.
    var orgID: String {
        return identityURL.deletingLastPathComponent().lastPathComponent
    }
    
    public init(identityURL: URL) {
        self.identityURL = identityURL
    }
}

extension UserIdentifier: RawRepresentable {
    
    public var rawValue: URL {
        return identityURL
    }
    
    public init(rawValue: URL) {
        self.identityURL = rawValue
    }
}

extension UserIdentifier: CustomStringConvertible {
    
    public var description: String {
        return "User identifier: org ID \(orgID); user ID \(userID)"
    }
}
