/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct ApexService: Service {
    public var method: String?
    public var namespace: String?
    public var relativePath: String
    public var queryItems: [URLQueryItem]?
    public var headers: [String:String]?
    public var body: Data?
}

extension ApexService {
    
    public var name: String {
        "apexrest"
    }
    
    public var path: String {
        let p = relativePath.starts(with: "/") ? relativePath : "/\(relativePath)"
        var ns = ""
        if let namespace = namespace {
            ns = "/\(namespace)"
        }
        return "/services/\(name)\(ns)\(p)"
    }
}

