//
//  Task.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.

import Foundation

public final class Task: Decodable {
	
	public var id: String = ""
	public var subject: String?
	public var createdDate: Date = Date()
	public var status: String?
	public var priority: String?
	public var isHighPriority: Bool = false
	public var relatedRecord: RelatedRecord?
	
	public struct RelatedRecord: Decodable {
		public var name: String
		enum CodingKeys: String, CodingKey {
			case name = "Name"
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case subject = "Subject"
		case createdDate = "CreatedDate"
		case status = "Status"
		case priority = "Priority"
		case isHighPriority = "IsHighPriority"
		case relatedRecord = "What"
	}
}
