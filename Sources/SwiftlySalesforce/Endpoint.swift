//
//  Endpoint.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

/// Each enum member represents an endpoint in the Salesforce REST API.
/// See: [Introducing Lightning Platform REST API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_what_is_rest_api.htm).
public enum Endpoint {
        
    case retrieve(type: String, id: String, fields: [String]?, version: String)
    case insert(type: String, data: Data, version: String)
    case update(type: String, id: String, data: Data, version: String)
    case delete(type: String, id: String, version: String)
        
    case query(soql: String, batchSize: Int?, version: String)
    case queryNext(path: String)
    
    case search(sosl: String, version: String)
        
    case describe(type: String, version: String)
    case describeLayout(type: String, version: String, id: String)
    case describeGlobal(version: String)
        
    case identity(version: String)
        
    case limits(version: String)
        
    case apex(method: HTTPMethod, path: String, parameters: [String: String]?, body: Data?, headers: [String: String]?)
        
    case smallFile(url: URL, mimeType: String?)
}

extension Endpoint: URLRequestConvertible {
    
    public func request(with credential: Credential) throws -> URLRequest {
        
        switch self {
                        
        case let .retrieve(type, id, fields, version):
            var comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/\(type)/\(id)")
            comps.queryItems = {
                if let fields = fields { return ["fields": fields.joined(separator: ",")].asURLQueryItems() }
                else { return nil }
            }()
            return try request(credential: credential, urlComponents: comps)
            
        case let .insert(type, data, version):
            let comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/\(type)/")
            return try request(credential: credential, urlComponents: comps, method: .post, body: data)
            
        case let .update(type, id, data, version):
            let comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/\(type)/\(id)")
            return try request(credential: credential, urlComponents: comps, method: .patch, body: data)
            
        case let .delete(type, id, version):
            let comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/\(type)/\(id)")
            return try request(credential: credential, urlComponents: comps, method: .delete)
                        
        case let .query(soql, batchSize, version):
            var comps = URLComponents(withPath: "/services/data/v\(version)/query")
            comps.queryItems = ["q": soql].asURLQueryItems()
            var headers = [String: String]()
            if let batchSize = batchSize {
                headers["Sforce-Query-Options"] = "batchSize=\(batchSize)"
            }
            return try request(credential: credential, urlComponents: comps, headers: headers)
            
        case let .queryNext(path):
            let comps = URLComponents(withPath: path)
            return try request(credential: credential, urlComponents: comps)
            
        case let .search(sosl, version):
            var comps = URLComponents(withPath: "/services/data/v\(version)/search/")
            comps.queryItems = ["q": sosl].asURLQueryItems()
            return try request(credential: credential, urlComponents: comps)
                        
        case let .describe(type, version):
            let comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/\(type)/describe")
            return try request(credential: credential, urlComponents: comps)
        
        case let .describeLayout(type, version, id):
            let comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/\(type)/describe/layout/\(id)")
            return try request(credential: credential, urlComponents: comps)

        case let .describeGlobal(version):
            let comps = URLComponents(withPath: "/services/data/v\(version)/sobjects/")
            return try request(credential: credential, urlComponents: comps)
                    
        case let .identity(version):
            guard var comps = URLComponents(url: credential.identityURL, resolvingAgainstBaseURL: false) else {
                throw URLError(URLError.badURL)
            }
            comps.queryItems = ["version": version].asURLQueryItems()
            return try request(credential: credential, urlComponents: comps)
                    
        case let .limits(version):
            let comps = URLComponents(withPath: "/services/data/v\(version)/limits")
            return try request(credential: credential, urlComponents: comps)
                        
        case let .apex(method, path, parameters, body, headers):
            var comps = URLComponents(withPath: "/services/apexrest\(path.starts(with: "/") ? "" : "/")\(path)")
            comps.queryItems = parameters?.asURLQueryItems()
            return try request(credential: credential, urlComponents: comps, headers: headers, method: method, body: body)
                
        case let .smallFile(url, mimeType):
            guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw URLError(URLError.badURL)
            }
            var headers = [String: String]()
            if let accept = mimeType {
                headers["Accept"] = accept
            }
            return try request(credential: credential, urlComponents: comps, headers: headers)
        }
    }
}

fileprivate extension URLComponents {
    
    init(withPath path: String) {
        self.init()
        self.path = path
    }
}
