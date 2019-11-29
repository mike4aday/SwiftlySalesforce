//
//  Salesforce+Search.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

public extension Salesforce {
    
    /// Asynchronously searches for records using Salesforce Object Search Language (SOSL)
    /// See [Salesforce Object Search Language (SOSL)](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl.htm).
    /// - Parameter sosl: SOSL string to use for search
    /// - Parameter config: Request configuration
    func search(sosl: String, config: RequestConfig = .shared) -> AnyPublisher<[Record], Error> {
        
        struct SearchResult: Decodable {
            public let searchRecords: [Record]
        }
        
        let resource = Endpoint.search(sosl: sosl, version: config.version)
        return request(requestConvertible: resource, config: config)
        .map { (results: SearchResult) -> [Record] in
            return results.searchRecords
        }
        .eraseToAnyPublisher()
    }
}
