import Foundation

public extension URLRequest {
    
    static let defaultTimeoutInterval: TimeInterval = 60.0
        
    init(
        credential: Credential,
        method: String? = nil,
        path: String,
        queryItems: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        cachePolicy: CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = URLRequest.defaultTimeoutInterval
    ) throws {
        
        // URL
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = credential.siteURL?.host ?? credential.instanceURL.host
        comps.path = path.starts(with: "/") ? path : "/\(path)"
        comps.percentEncodedQuery = queryItems.flatMap { String(byPercentEncoding: $0) }
        guard let url = comps.url else {
            throw URLError(.badURL)
        }
        
        // URLRequest
        self = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        self.httpMethod = method
        self.httpBody = body
        
        // Headers
        let contentType: String = {
            switch self.httpMethod?.uppercased() {
            case nil, HTTP.Method.get.uppercased(), HTTP.Method.delete.uppercased():
                return HTTP.MIMEType.formUrlEncoded
            default:
                return HTTP.MIMEType.json
            }
        }()
        let defaultHeaders: [String:String] = [
            HTTP.Header.accept : HTTP.MIMEType.json,
            HTTP.Header.contentType : contentType
        ].reduce(into: [:]) { $0[$1.0] = $1.1 }
        self.allHTTPHeaderFields = defaultHeaders.merging(headers ?? [:]) { (_, new) in new }
        self.setAuthorizationHeader(with: credential.accessToken)
    }
    
    static func identity(with credential: Credential) -> Self {
        var req = URLRequest(url: credential.identityURL)
        req.setValue(HTTP.MIMEType.json, forHTTPHeaderField: HTTP.Header.accept)
        req.setAuthorizationHeader(with: credential.accessToken)
        return req
    }
    
    mutating func setAuthorizationHeader(with accessToken: String) {
        setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
}
