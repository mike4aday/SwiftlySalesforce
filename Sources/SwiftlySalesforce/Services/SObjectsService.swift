/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct SObjectsService: Service {
    
    public var name: String = "sobjects"
    public var endpoint: Endpoint
    public var version: Version
    
    public init(_ endpoint: Endpoint, version: Version = .default) {
        self.endpoint = endpoint
        self.version = version
    }
}

public extension SObjectsService {
    
    struct Endpoint {
        
        public var method: String = HTTP.Method.get
        public var path: String
        public var body: Data? = nil
        public var queryItems: [URLQueryItem]? = nil
        
        private static let encoder: JSONEncoder = .salesforce

        public static func create<T: Encodable>(type: String, fields: [String:T]) throws -> Endpoint {
            return Endpoint(method: HTTP.Method.post, path: "\(type)", body: try encoder.encode(fields))
        }
        
        public static func read(type: String, id: String, fields: [String]? = nil) -> Endpoint {
            var queryItems: [URLQueryItem]? = nil
            if let fields = fields {
                queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
            }
            return Endpoint(path: "\(type)/\(id)", queryItems: queryItems)
        }
        
        public static func update<T: Encodable>(type: String, id: String, fields: [String:T]) throws -> Endpoint {
            return Endpoint(method: HTTP.Method.patch, path: "\(type)/\(id)", body: try encoder.encode(fields))
        }
        
        public static func delete(type: String, id: String) -> Endpoint {
            return Endpoint(method: HTTP.Method.delete, path: "\(type)/\(id)")
        }
        
        public static func describe(type: String) -> Endpoint {
            return Endpoint(path: "\(type)/describe")
        }
        
        public static var describeAll: Endpoint {
            return Endpoint(path: "")
        }
    }
}

extension SObjectsService {
    
    public var path: String {
        return "\(root)/\(name)/\(endpoint.path)"
    }
    
    public var method: String? {
        endpoint.method
    }
    
    public var body: Data? {
        endpoint.body
    }
    
    public var queryItems: [URLQueryItem]? {
        endpoint.queryItems
    }
}
