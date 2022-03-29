import Foundation

extension Resource {
    
    struct Limits: DataService {
        
        typealias Output = [String: Limit]
                
        func createRequest(with credential: Credential) throws -> URLRequest {
            let path = Resource.path(for: "limits")
            return try URLRequest(credential: credential, path: path)
        }
    }
}
