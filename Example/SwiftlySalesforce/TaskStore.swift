//
//  TaskStore.swift
//  Example for SwiftlySalesforce
//
//  Created by Michael Epstein on 10/21/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SwiftlySalesforce

public final class TaskStore {
	
	/// Singleton
	public static let shared = TaskStore()
	
	public fileprivate(set) var cache: [Task]?
	
	public func getTasks(refresh: Bool = false) -> Promise<[Task]> {
		
		return Promise<[Task]> {
			fulfill, reject in
			if let tasks = self.cache, !refresh {
				fulfill(tasks)
			}
			else {
				first {
					// Get ID of current user
					//TODO: if user already authorized, then we could just get this from salesforce.authData
					salesforce.identity()
				}.then {
					// Get tasks owned by user
					userInfo in
					guard let userID = userInfo.userID else {
						throw TaskForceError.generic(code: 100, message: "Can't determine user ID")
					}
					let soql = "SELECT Id,Subject,Status,What.Name FROM Task WHERE OwnerId = '\(userID)' ORDER BY CreatedDate DESC"
					return salesforce.query(soql: soql)
				}.then {
					// Parse JSON into Task instances and cache in memory
					(result: QueryResult) -> () in
					let tasks = result.records.map { Task(dictionary: $0) }
					self.cache = tasks
					fulfill(tasks)
				}.catch {
					error in
					reject(error)
				}
			}
		}
	}
	
	/// Called on logout to clear locally-cached data
	public func clear() {
		cache = nil
	}
}
