//
//  Salesforce+Apex.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

extension Salesforce {
    
    /// Asynchronously calls an Apex method exposed as a REST endpoint.
    /// See [Exposing Apex Classes as REST Web Services](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest.htm).
    /// - Parameter method: HTTP method; defaults to "GET"
    /// - Parameter path: String that gets appended to instance URL; should begin with "/"
    /// - Parameter parameters: Dictionary of query string parameters
    /// - Parameter body: Data to be sent in the body of the request, e.g. JSON as Data in the body of a POST request
    /// - Parameter headers: Dictionary of HTTP header values
    /// - Parameter config: Request configuration options
    public func apex<T: Decodable>(
        method: HTTPMethod = .get,
        path: String,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil,
        config: RequestConfig = .shared) -> AnyPublisher<T, Error> {
        
        let endpoint = Endpoint.apex(method: method, path: path, parameters: parameters, body: body, headers: headers)
        return request(requestConvertible: endpoint, config: config)
    }
}
