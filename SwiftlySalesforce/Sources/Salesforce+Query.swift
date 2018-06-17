//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import PromiseKit

extension Salesforce {
	
	/// Asynchronsouly executes a SOQL query.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Parameter batchSize: Number of records returned in query request,
	///				including child objects. Must be nil or Int between 200 and 2000.
	///				See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers_queryoptions.htm
	/// - Parameter	shouldAuthorize: If true and user authentication is required, OAuth2 user-agent flow will start
	/// - Returns:	Promise of a QueryResult whose records, if any, are decoded as generic type 'T'
	open func query<T: Decodable>(soql: String, batchSize: Int? = nil, shouldAuthorize: Bool = true) -> Promise<QueryResult<T>> {
		let resource = QueryResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(resource: resource, shouldAuthorize: shouldAuthorize)
	}
	
	/// Asynchronsouly executes a SOQL query.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Parameter batchSize: Number of records returned in query request,
	///				including child objects. Must be nil or Int between 200 and 2000.
	///				See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers_queryoptions.htm
	/// - Parameter	shouldAuthorize: If true and user authentication is required, OAuth2 user-agent flow will start
	/// - Returns: 	Promise of a QueryResult whose records, if any, are decoded as generic type 'T'
	open func query(soql: String, batchSize: Int? = nil, shouldAuthorize: Bool = true) -> Promise<QueryResult<Record>> {
		let resource = QueryResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(resource: resource, shouldAuthorize: shouldAuthorize)
	}
	
	/// Asynchronsouly executes multiple SOQL queries.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: Array of SOQL queries
	/// - Parameter batchSize: Number of records returned in query request,
	///				including child objects. Must be nil or Int between 200 and 2000.
	///				See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers_queryoptions.htm
	/// - Parameter	shouldAuthorize: If true and user authentication is required, OAuth2 user-agent flow will start
	/// - Returns: 	Promise of an array of QueryResults, in the same order as the "soql" parameter
	open func query<T: Decodable>(soql: [String], batchSize: Int? = nil, shouldAuthorize: Bool = true) -> Promise<[QueryResult<T>]> {
		let promises: [Promise<QueryResult<T>>] = soql.map { query(soql: $0, batchSize: batchSize, shouldAuthorize: shouldAuthorize) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronsouly executes multiple SOQL queries (non-generic function version).
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: Array of SOQL queries
	/// - Parameter batchSize: Number of records returned in a query request,
	///				including child objects. Must be nil or Int between 200 and 2000.
	///				See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers_queryoptions.htm
	/// - Parameter	shouldAuthorize: If true and user authentication is required, OAuth2 user-agent flow will start
	/// - Returns: 	Promise of an array of QueryResults, in the same order as the "soql" parameter
	open func query(soql: [String], batchSize: Int? = nil, shouldAuthorize: Bool = true) -> Promise<[QueryResult<Record>]> {
		let promises: [Promise<QueryResult<Record>>] = soql.map { query(soql: $0, batchSize: batchSize, shouldAuthorize: shouldAuthorize) }
		return when(fulfilled: promises)
	}
	
	/// Queries next pages of records returned by a SOQL query whose result is broken into multiple pages.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult.
	/// - Parameter batchSize: Number of records returned in query request,
	///				including child objects. Must be nil or Int between 200 and 2000.
	///				See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers_queryoptions.htm
	/// - Parameter	shouldAuthorize: If true and user authentication is required, OAuth2 user-agent flow will start
	/// - Returns: 	Promise of a QueryResult
	open func queryNext<T: Decodable>(path: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<T>> {
		let resource = QueryResource.queryNext(path: path)
		return dataTask(resource: resource, shouldAuthorize: shouldAuthorize)
	}
	
	/// Queries next page of records returned by a SOQL query whose result is broken into pages.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult.
	/// - Parameter batchSize: Number of records returned in query request,
	///				including child objects. Must be nil or Int between 200 and 2000.
	///				See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers_queryoptions.htm
	/// - Parameter	shouldAuthorize: If true and user authentication is required, OAuth2 user-agent flow will start
	/// - Returns: 	Promise of a QueryResult
	open func queryNext(path: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<Record>> {
		return dataTask(resource: QueryResource.queryNext(path: path), shouldAuthorize: shouldAuthorize)
	}
}
