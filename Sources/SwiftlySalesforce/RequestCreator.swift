import Foundation

public protocol RequestCreator {
    
    func createRequest(with: Credential) throws -> URLRequest
}
