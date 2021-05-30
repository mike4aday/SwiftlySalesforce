/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public protocol Service {
    
    var name: String { get }
    var version: Version { get }
    var root: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var method: String? { get }
    var headers: [String:String]? { get }
    var body: Data? { get }
    
    func buildRequest(with credential: Credential) throws -> URLRequest
}

// Default implementations
public extension Service {
    
    var name: String { "" }
    var version: Version { .default }
    var root: String { "/services/data/v\(version)" }
    var path: String { "\(root)/\(name)" }
    var queryItems: [URLQueryItem]? { nil }
    var method: String? { nil }
    var headers: [String:String]? { nil }
    var body: Data? { nil }
    
    func buildRequest(with credential: Credential) throws -> URLRequest {
        
        // URL
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = credential.instanceURL.host
        comps.path = path.starts(with: "/") ? path : "/\(path)"
        comps.queryItems = queryItems
        guard let url = comps.url else {
            throw URLError(.badURL)
        }
        
        // URLRequest
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        
        // Headers
        let contentType: String = {
            switch req.httpMethod?.uppercased() {
            case nil, HTTP.Method.get.uppercased(), HTTP.Method.delete.uppercased():
                return HTTP.MIMEType.formUrlEncoded
            default:
                return HTTP.MIMEType.json
            }
        }()
        let defaultHeaders: [String:String] = [
            HTTP.Header.authorization(accessToken: credential.accessToken),
            HTTP.Header.accept(HTTP.MIMEType.json),
            HTTP.Header.contentType(contentType)
        ].reduce(into: [:]) { $0[$1.0] = $1.1 }
        req.allHTTPHeaderFields = defaultHeaders.merging(headers ?? [:]) { (_, new) in new }
        
        return req
    }
}
