//
//  SearchResult.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

/// Holds the result of a Salesforce Object Search Language (SOSL) query
/// See https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl.htmpublic

public struct SearchResult: Decodable {
	
	public let searchRecords: [SObject]
}
