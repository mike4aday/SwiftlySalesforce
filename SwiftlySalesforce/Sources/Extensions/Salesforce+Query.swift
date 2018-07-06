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
	/// - Parameter batchSize: maximum number of records returned per result set (i.e. pagination)
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a QueryResult whose records, if any, are decoded as generic type 'T'
	public func query<T: Decodable>(soql: String, batchSize: Int? = nil, options: Options = []) -> Promise<QueryResult<T>> {
		let resource = QueryResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(with: resource, options: options)
	}
	
	public func query(soql: String, batchSize: Int? = nil, options: Options = []) -> Promise<QueryResult<SObject>> {
		let resource = QueryResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(with: resource, options: options)
	}
	
	public func query<T: Decodable>(soql: [String], batchSize: Int? = nil, options: Options = []) -> Promise<[QueryResult<T>]> {
		let promises: [Promise<QueryResult<T>>] = soql.map { query(soql: $0, batchSize: batchSize, options: options) }
		return when(fulfilled: promises)
	}
	
	public func query(soql: [String], batchSize: Int? = nil, options: Options = []) -> Promise<[QueryResult<SObject>]> {
		let promises: [Promise<QueryResult<SObject>>] = soql.map { query(soql: $0, batchSize: batchSize, options: options) }
		return when(fulfilled: promises)
	}
	
	public func queryNext<T: Decodable>(path: String, options: Options = []) -> Promise<QueryResult<T>> {
		let resource = QueryResource.queryNext(path: path)
		return dataTask(with: resource, options: options)
	}
	
	public func queryNext(path: String, options: Options = []) -> Promise<QueryResult<SObject>> {
		let resource = QueryResource.queryNext(path: path)
		return dataTask(with: resource, options: options)
	}
}
