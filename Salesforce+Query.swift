//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import PromiseKit

extension Salesforce {
	
	open func query(soql: String, shouldAuthorize: Bool = true) -> Promise<QueryResult<Record>> {
		return dataTask(resource: .query(soql: soql, version: version), shouldAuthorize: shouldAuthorize)
	}
}
