//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import PromiseKit

extension Salesforce {
	
	/// Asynchronsouly executes a SOQL query
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Returns: Promise of a QueryResult whose records, if any, are decoded as Records
/*	open func query(soql: String) -> Promise<QueryResult<Record>> {
		let resource = Resource.query(soql: soql, version: version)
		return requestor.request(resource: resource, connectedApp: connectedApp).then(on: q) {
			return try self.decoder.decode(QueryResult<Record>.self, from: $0)
		}
	}*/
}
