import Foundation

struct IdentityService: DataService {
            
    public func createRequest(with credential: Credential) throws -> URLRequest {
        return URLRequest.identity(with: credential)
    }
    
    public func checkAuthenticationRequired(response: Response<Data>) throws {
        guard 403 != response.metadata.statusCode else {
            throw URLError(.userAuthenticationRequired)
        }
    }
    
    public func transform(data: Data) throws -> Identity {
        try JSONDecoder(dateDecodingStrategy: .iso8601).decode(Identity.self, from: data)
    }
}
