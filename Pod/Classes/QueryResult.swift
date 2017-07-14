//
//  QueryResult.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//


/// Holds the result of a SOQL query
/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
public struct QueryResult {
	
	public let totalSize: Int
	public let isDone: Bool
	public let records: [Record]
	public let nextRecordsPath: String?
	
	public init(json: [String: Any]) throws {
		guard
			let totalSize = json["totalSize"] as? Int,
			let isDone = json["done"] as? Bool,
			let records = json["records"] as? [[String: Any]] else {
				throw SerializationError.invalid(json, message: "Unable to create QueryResult")
		}
		self.totalSize = totalSize
		self.isDone = isDone
		self.records = records
		self.nextRecordsPath = json["nextRecordsUrl"] as? String
	}
}
