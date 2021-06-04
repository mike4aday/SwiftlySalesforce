/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct QueryService: Service {
    
    public var name: String = "query"
    public var endpoint: Endpoint
    public var version: Version = .default
    
    init(_ endpoint: Endpoint, version: Version = .default) {
        self.endpoint = endpoint
        self.version = version 
    }
}

public extension QueryService {
    
    struct Endpoint {
        
        public var path: String? = nil
        public var queryItems: [URLQueryItem]? = nil
        public var headers: [String:String]? = nil
        
        public static func execute(soql: String, batchSize: Int = 2000) -> Endpoint {
            let queryItems = [URLQueryItem(name: "q", value: soql)]
            let headers = ["Sforce-Query-Options" : "batchSize=\(batchSize)"]
            return Endpoint(queryItems: queryItems, headers: headers)
        }
        
        public static func nextResultPage(at path: String) -> Endpoint {
            return Endpoint(path: path)
        }
    }
}

extension QueryService {
    
    public var path: String {
        guard let p = endpoint.path else {
            return "\(root)/\(name)"
        }
        return p
    }
    
    public var queryItems: [URLQueryItem]? {
        endpoint.queryItems
    }
    
    public var headers: [String:String]? {
        endpoint.headers
    }
}
