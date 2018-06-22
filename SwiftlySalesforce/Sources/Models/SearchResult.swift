//
//  SearchResult.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/21/18.
//

import Foundation

/// Holds the result of a Salesforce Object Search Language (SOSL) query
/// See https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl.htmpublic

public struct SearchResult: Decodable {
	
	public let searchRecords: [Record]
}
