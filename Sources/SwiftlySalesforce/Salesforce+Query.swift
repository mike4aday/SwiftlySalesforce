//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

extension Salesforce {
    
    /// Asynchronsouly executes a SOQL query.
    /// See [Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm).
    /// - Parameter soql: SOQL query
    /// - Parameter batchSize: Number of records returned per result set; minimum 200, maximum 2000
    /// - Parameter config: Request configuration
    public func query<T: Decodable>(soql: String, batchSize: Int? = nil, config: RequestConfig = .shared) -> AnyPublisher<QueryResult<T>, Error> {
        let resource = Endpoint.query(soql: soql, batchSize: batchSize, version: config.version)
        return request(requestConvertible: resource, config: config)
    }
    
    /// Asynchronsouly executes a SOQL query.
    /// See [Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm).
    /// - Parameter soql: SOQL query
    /// - Parameter batchSize: Number of records returned per result set; minimum 200, maximum 2000
    /// - Parameter config: Request configuration
    public func query(soql: String, batchSize: Int? = nil, config: RequestConfig = .shared) -> AnyPublisher<QueryResult<Record>, Error> {
        let resource = Endpoint.query(soql: soql, batchSize: batchSize, version: config.version)
        return request(requestConvertible: resource, config: config)
    }
    
    /// Queries next pages of records returned by a SOQL query whose result is broken into multiple pages.
    /// See: [Retrieving the Remaining SOQL Query Results](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm)
    /// - Parameter path: The 'nextRecordsPath' property of a previously-obtained QueryResult
    /// - Parameter config: Request configuration options
    public func queryNext<T: Decodable>(path: String, config: RequestConfig = .shared) -> AnyPublisher<QueryResult<T>, Error> {
        let resource = Endpoint.queryNext(path: path)
        return request(requestConvertible: resource, config: config)
    }
    
    /// Queries next pages of records returned by a SOQL query whose result is broken into multiple pages.
    /// See: [Retrieving the Remaining SOQL Query Results](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm)
    /// - Parameter path: The 'nextRecordsPath' property of a previously-obtained QueryResult
    /// - Parameter config: Request configuration options
    public func queryNext(path: String, config: RequestConfig = .shared) -> AnyPublisher<QueryResult<Record>, Error> {
        let resource = Endpoint.queryNext(path: path)
        return request(requestConvertible: resource, config: config)
    }
}
