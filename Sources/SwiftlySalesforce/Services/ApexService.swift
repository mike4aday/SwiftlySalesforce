import Foundation

struct ApexService<T: Decodable>: DataService {
        
    typealias Output = T
    
    let path: String
    
    var method: String? = nil 
    var queryItems: [String: String]? = nil
    var headers: [String:String]? = nil
    var body: Data? = nil
    var timeoutInterval: TimeInterval = URLRequest.defaultTimeoutInterval
    
    func createRequest(with credential: Credential) throws -> URLRequest {
        return try URLRequest(
            credential: credential,
            method: method,
            path: "/services/apexrest\(path.starts(with: "/") ? path : "/\(path)")",
            queryItems: queryItems,
            headers: headers,
            body: body,
            timeoutInterval: timeoutInterval
        )
    }
}
