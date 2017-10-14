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
					userInfo -> Promise<QueryResult<Task>> in
					let soql = "SELECT Id,CreatedDate,Subject,Status,IsHighPriority,What.Name FROM Task WHERE OwnerId = '\(userInfo.userID)' ORDER BY CreatedDate DESC"
					return salesforce.query(soql: soql)
				}.then {
					// Parse JSON into Task instances and cache in memory
					(result: QueryResult) -> () in
					let tasks = result.records
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
