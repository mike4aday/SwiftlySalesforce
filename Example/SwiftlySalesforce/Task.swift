//
//  Task.swift
//  Example for SwiftlySalesforce
//
//  Created by Michael Epstein on 10/21/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

public final class Task {
	
	public var id: String?
	public var subject: String?
	public var dueDate: Date?
	public var createdDate: Date?
	public var whatName: String?
	public var whatType: String?
	public var status: String?
	public var priority: String?
	public var isHighPriority: Bool = false
	
	public init() { }
	
	/// Creates instance from JSON returned by Salesforce REST API
	/// - Parameter dictionary: JSON object returned by Salesforce
	public init(dictionary: [String: Any]) {
		
		for (key, value) in dictionary {
			switch key.lowercased() {
			case "id":
				self.id = value as? String
			case "subject":
				self.subject = value as? String
			case "activitydate":
				if let s = value as? String {
					self.dueDate = DateFormatter.salesforceDateFormatter.date(from: s)
				}
			case "createddate":
				if let s = value as? String {
					self.createdDate = DateFormatter.salesforceDateTimeFormatter.date(from: s)
				}
			case "what":
				if let dict = value as? [String: Any] {
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
