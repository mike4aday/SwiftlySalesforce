//
//  Task.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation


public final class Task {
	
	public var id: String?
	public var subject: String?
	public var dueDate: NSDate?
	public var createdDate: NSDate?
	public var whatName: String?
	public var whatType: String?
	public var status: String?
	public var priority: String?
	public var isHighPriority: Bool = false
	
	public init() { }
	
	/// Creates instance from JSON returned by Salesforce REST API
	/// - Parameter dictionary: JSON object returned by Salesforce
	public init(dictionary: [String: AnyObject]) {
	
		for (key, value) in dictionary {
			switch key.lowercaseString {
			case "id":
				self.id = value as? String 
			case "subject":
				self.subject = value as? String
			case "activitydate":
				if let s = value as? String {
					self.dueDate = NSDateFormatter.SalesforceDate.dateFromString(s)
				}
			case "createddate":
				if let s = value as? String {
					self.createdDate = NSDateFormatter.SalesforceDateTime.dateFromString(s)
				}
			case "what":
				if let dict = value as? [String: AnyObject] {
					self.whatName = dict["Name"] as? String
					self.whatType = dict["Type"] as? String 
				}
			case "status":
				self.status = value as? String
			case "priority":
				self.priority = value as? String
			case "ishighpriority":
				self.isHighPriority = (value as? Int) == 1
			default:
				continue
			}
		}
	}
}