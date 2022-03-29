import Foundation

public extension URLComponents {
    
    init(scheme: String = "https", host: String, path: String, queryParameters: Dictionary<String, String>? = nil) {
        self.init()
        self.scheme = scheme
        self.host = host
        self.path = path
        queryParameters.map { self.queryItems = .init($0) }
    }
    
    init(percentEncodedQuery: String) {
        self.init()
        self.percentEncodedQuery = percentEncodedQuery
    }
}
