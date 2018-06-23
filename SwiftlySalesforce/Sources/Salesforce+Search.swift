//
//  Salesforce+Search.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension Salesforce {
	
	public func search(sosl: String, options: Options = []) -> Promise<SearchResult> {
		let resource = SearchResource.search(sosl: sosl, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
}
