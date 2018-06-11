//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import PromiseKit

extension Salesforce {
	
	open func query(soql: String) -> Promise<QueryResult<Record>> {
		let resource = Resource.query(soql: soql)
		return dataTask(with: resource).map { data in
			print(String(data: data, encoding: .utf8))
			return try JSONDecoder().decode(QueryResult<Record>.self, from: data)
		}
	}
}

extension Salesforce {
	
	func dataTask(with resource: Resource) -> Promise<Data> {
		
		let go: (URLRequest) -> Promise<Data> = { request -> Promise<Data> in
			return URLSession.shared.dataTask(.promise, with: request).map { (data, response) -> Data in
				return data
			}
		}
		
		return Promise<Authorization> { seal in
			seal.resolve(self.authorization, RequestError.userAuthenticationRequired)
		}.then {
			try go(resource.urlRequest(with: $0))
		}.recover {
			(error: Error) -> Promise<Data> in
			if case RequestError.userAuthenticationRequired = error {
				return self.authorize().then { authorization in
					try go(resource.urlRequest(with: authorization))
				}
			}
			else {
				throw error
			}
		}
	}
	
	public enum RequestError: Error {
		case userAuthenticationRequired
		case resourceNotFound
		case unknownError(httpStatusCode: Int)
		
	}
}
