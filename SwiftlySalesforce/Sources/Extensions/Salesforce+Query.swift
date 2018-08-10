//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation
import PromiseKit

public extension Salesforce {
	
	/// Asynchronsouly executes a SOQL query.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Parameter batchSize: number of records returned per result set; minimum 200, maximum 2000
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a QueryResult whose records, if any, are decoded as generic type 'T'
	public func query<T: Decodable>(soql: String, batchSize: Int? = nil, options: Options = []) -> Promise<QueryResult<T>> {
		let resource = QueryResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(with: resource, options: options)
	}
	
	/// Asynchronsouly executes a SOQL query
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Parameter batchSize: number of records returned per result set; minimum 200, maximum 2000
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a QueryResult whose records, if any, are decoded as SObjects
	public func query(soql: String, batchSize: Int? = nil, options: Options = []) -> Promise<QueryResult<SObject>> {
		let resource = QueryResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(with: resource, options: options)
	}
	
	/// Asynchronsouly executes multiple SOQL queries in parallel.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: Array of SOQL queries
	/// - Parameter batchSize: number of records returned per result set; minimum 200, maximum 2000
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of an array of QueryResults, in the same order as the "soql" parameter
	public func query<T: Decodable>(soql: [String], batchSize: Int? = nil, options: Options = []) -> Promise<[QueryResult<T>]> {
		let promises: [Promise<QueryResult<T>>] = soql.map { query(soql: $0, batchSize: batchSize, options: options) }
		return when(fulfilled: promises)
	}
	
	public func query(soql: [String], batchSize: Int? = nil, options: Options = []) -> Promise<[QueryResult<SObject>]> {
		let promises: [Promise<QueryResult<SObject>>] = soql.map { query(soql: $0, batchSize: batchSize, options: options) }
		return when(fulfilled: promises)
	}
	
	/// Queries next pages of records returned by a SOQL query whose result is broken into multiple pages.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a QueryResult
	public func queryNext<T: Decodable>(path: String, options: Options = []) -> Promise<QueryResult<T>> {
		let resource = QueryResource.queryNext(path: path)
		return dataTask(with: resource, options: options)
	}
	
	/// Queries next page of records returned by a SOQL query whose result is broken into pages.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult.
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a QueryResult
	public func queryNext(path: String, options: Options = []) -> Promise<QueryResult<SObject>> {
		let resource = QueryResource.queryNext(path: path)
		return dataTask(with: resource, options: options)
	}
}
