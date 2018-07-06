//
//  Salesforce+Search.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension Salesforce {
	
	/// Asynchronously searches for records using Salesforce Object Search Language (SOSL)
	/// See https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl.htm
	/// - Parameter sosl: SOSL string to use for search
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of SearchResult
	public func search(sosl: String, options: Options = []) -> Promise<SearchResult> {
		let resource = SearchResource.search(sosl: sosl, version: configuration.version)
		return dataTask(with: resource, options: options)
	}
}
