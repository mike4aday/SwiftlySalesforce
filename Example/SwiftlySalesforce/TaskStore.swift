//
//  TaskStore.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import SwiftlySalesforce
import PromiseKit


public final class TaskStore {
	
	/// Singleton
	public static let sharedInstance = TaskStore()
	
	public private(set) var cache: [Task]?
	
	public func getTasks(refresh refresh: Bool) -> Promise<[Task]> {
		
		return Promise<[Task]> {
			
			(fulfill, reject) -> () in
			
			if let tasks = self.cache where !refresh {
				fulfill(tasks)
			}
			else {
				firstly {
					SalesforceAPI.Identity.request()
				}.then {
					// Get user ID
					(identityInfo) -> String in
					guard let userID = identityInfo["user_id"] as? String else {
						throw NSError(domain: "TaskForce", code: -100, userInfo: nil)
					}
					return userID
				}.then {
					// Query tasks owned by user
					(userID) -> Promise<AnyObject> in
					let soql = "SELECT Id,Subject,Status,What.Name FROM Task WHERE OwnerId = '\(userID)' ORDER BY CreatedDate DESC"
					return SalesforceAPI.Query(soql: soql).request()
				}.then {
					// Parse JSON response into Task instances
					(result) -> () in
					guard let records = result["records"] as? [[String: AnyObject]] else {
						throw NSError(domain: "TaskForce", code: -101, userInfo: nil)
					}
					let tasks = records.map { Task(dictionary: $0) }
					self.cache = tasks
					fulfill(tasks)
				}.error {
					// Errors, e.g. loss of Internet connectivity, will be caught here
					(error) -> Void in
					reject(error)
				}
			}
		}
	}
	
	/// Called on logout to clear locally-cached data
	internal func clear() {
		cache = nil
	}
}


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