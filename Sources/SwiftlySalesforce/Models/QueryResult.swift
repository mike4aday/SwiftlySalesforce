//
//  QueryResult.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

/// Holds the result of a SOQL query.
/// See [Execute a SOQL Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm).
public struct QueryResult<T: Decodable>: Decodable {
    
    public let totalSize: Int
    public let isDone: Bool
    public let records: [T]
    public let nextRecordsPath: String?
    
    enum CodingKeys: String, CodingKey {
        case totalSize
        case isDone = "done"
        case records
        case nextRecordsPath = "nextRecordsUrl"
    }
}
