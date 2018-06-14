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
	/// - Parameter shouldAuthorize: If true, OAuth2 user-agent flow will start if authentication is required
	/// - Returns: Promise of a QueryResult whose records, if any, are decoded as generic type 'T'
	open func query<T: Decodable>(soql: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<T>> {
		return dataTask(resource: .query(soql: soql, version: version), shouldAuthorize: shouldAuthorize)
	}
	
	/// Asynchronsouly executes a SOQL query.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Parameter shouldAuthorize: If true, OAuth2 user-agent flow will start if authentication is required
	/// - Returns: Promise of a QueryResult whose records, if any, are decoded as generic type 'T'
	open func query(soql: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<Record>> {
		return dataTask(resource: .query(soql: soql, version: version), shouldAuthorize: shouldAuthorize)
	}
	
	/// Asynchronsouly executes multiple SOQL queries.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: Array of SOQL queries
	/// - Parameter shouldAuthorize: If true, OAuth2 user-agent flow will start if authentication is required
	/// - Returns: Promise of an array of QueryResults, in the same order as the "soql" parameter
	open func query<T: Decodable>(soql: [String]) -> Promise<[QueryResult<T>]> {
		let promises: [Promise<QueryResult<T>>] = soql.map { query(soql: $0) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronsouly executes multiple SOQL queries (non-generic function version).
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: Array of SOQL queries
	/// - Parameter shouldAuthorize: If true, OAuth2 user-agent flow will start if authentication is required
	/// - Returns: Promise of an array of QueryResults, in the same order as the "soql" parameter
	open func query(soql: [String]) -> Promise<[QueryResult<Record>]> {
		let promises: [Promise<QueryResult<Record>>] = soql.map { query(soql: $0) }
		return when(fulfilled: promises)
	}
	
	/// Queries next pages of records returned by a SOQL query whose result is broken into multiple pages.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult.
	/// - Parameter shouldAuthorize: If true, OAuth2 user-agent flow will start if authentication is required
	/// - Returns: Promise of a QueryResult
	open func queryNext<T: Decodable>(path: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<T>> {
		return dataTask(resource: .queryNext(path: path), shouldAuthorize: shouldAuthorize)
	}
	
	/// Queries next page of records returned by a SOQL query whose result is broken into pages.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult.
	/// - Parameter shouldAuthorize: If true, OAuth2 user-agent flow will start if authentication is required
	/// - Returns: Promise of a QueryResult
	open func queryNext(path: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<Record>> {
		return dataTask(resource: .queryNext(path: path), shouldAuthorize: shouldAuthorize)
	}
}
