//
//  Salesforce+SObject.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation
import PromiseKit

public extension Salesforce {
	
	//MARK: - Retrieve methods
	
	/// Asynchronously retrieves a single record.
	/// - Parameter type: The type of the record, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter id: ID of the record to retrieve
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a Decodable instance
	public func retrieve<T: Decodable>(type: String, id: String, fields: [String]? = nil, options: Options = []) -> Promise<T> {
		let resource = SObjectResource.retrieve(type: type, id: id, fields: fields, version: config.version)
		return dataTask(with: resource, options: options)
	}
	
	/// Asynchronously retrieves a single record (non-generic function version).
	/// - Parameter type: The type of the record, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter id: ID of the record to retrieve
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a Record instance
	public func retrieve(type: String, id: String, fields: [String]? = nil, options: Options = []) -> Promise<SObject> {
		let resource = SObjectResource.retrieve(type: type, id: id, fields: fields, version: config.version)
		return dataTask(with: resource, options: options)
	}
	
	/// Asynchronously retrieves multiple records of the same type, by ID.
	/// - Parameter type: The type of the records to retrieve, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter ids: IDs of the records to retrieve. All records must be of the same type.
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of an array of Decodable instances
	public func retrieve<T: Decodable>(type: String, ids: [String], fields: [String]? = nil, options: Options = []) -> Promise<[T]> {
		let promises: [Promise<T>] = ids.map { retrieve(type: type, id: $0, fields: fields) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously retrieves multiple records of the same type, by ID (non-generic version).
	/// - Parameter type: The type of the records to retrieve, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter ids: IDs of the records to retrieve. All records must be of the same type.
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of an array of Record instances in the same order as the "ids" parameter
	public func retrieve(type: String, ids: [String], fields: [String]? = nil, options: Options = []) -> Promise<[SObject]> {
		let promises: [Promise<SObject>] = ids.map { retrieve(type: type, id: $0, fields: fields) }
		return when(fulfilled: promises)
	}
	
	// MARK: - Insert methods
	
	/// Asynchronously creates a new record in Salesforce
	/// - Parameter type: The type of the record to be inserted, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter record: an Encodable object that will be inserted as a new record in Salesforce
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a string which holds the ID of the newly-inserted record
	public func insert<T: Encodable>(type: String, record: T, options: Options = []) -> Promise<String> {
		return firstly { () -> Promise<InsertResult> in
			let data = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(record)
			let resource = SObjectResource.insert(type: type, data: data, version: config.version)
			return dataTask(with: resource, options: options)
		}.map { $0.id }
	}
	
	/// Ansynchronously creates a new record in Salesforce
	public func insert(record: SObject, options: Options = []) -> Promise<String> {
		return insert(type: record.type, record: record, options: options)
	}
	
	/// Asynchronously creates a new record in Salesforce
	/// - Parameter type: The type of the record to be inserted, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter fields: Dictionary of field names and values to be set on the newly-inserted record.
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a string which holds the ID of the newly-inserted record
	public func insert(type: String, fields: [String: Encodable?], options: Options = []) -> Promise<String> {
		let record = SObject(type: type, fields: fields)
		return insert(type: type, record: record, options: options)
	}
	
	// MARK: - Update methods
	
	/// Asynchronously updates a record in Salesforce
	/// - Parameter type: Type of record to be updated (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be updated
	/// - Parameter record: record with updates (record should not encode an "Id" property, or other non-updateable fields)
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise<Void>
	public func update<T: Encodable>(type: String, id: String, record: T, options: Options = []) -> Promise<Void> {
		return firstly { () -> Promise<DataResponse> in
			let data = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(record)
			let resource = SObjectResource.update(type: type, id: id, data: data, version: config.version)
			return dataTask(with: resource, options: options)
		}.done { _ in return }
	}
	
	/// Asynchronously updates a record in Salesforce
	/// - Parameter record: SObject instance used for update
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise<Void>
	public func update(record: SObject, options: Options = []) -> Promise<Void> {
		guard let id = record.id else {
			return Promise(error: Salesforce.Error.invalidArgument(name: "record", value: nil, message: "Record ID can't be nil."))
		}
		return update(type: record.type, id: id, record: record)
	}
	
	/// Asynchronously updates a record in Salesforce
	/// - Parameter type: Type of record to be updated (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be updated
	/// - Parameter fields: Dictionary of updated field name and value pairs.
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise<Void>
	public func update(type: String, id: String, fields: [String: Encodable?], options: Options = []) -> Promise<Void> {
		let record = SObject(type: type, fields: fields)
		return update(type: type, id: id, record: record)
	}
	
	// MARK: - Delete methods
	
	/// Asynchronously deletes a record
	/// - Parameter type: Type of record to be deleted (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be deleted
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise<Void>
	public func delete(type: String, id: String, options: Options = []) -> Promise<Void> {
		let resource = SObjectResource.delete(type: type, id: id, version: config.version)
		return dataTask(with: resource, options: options).done { _ in return }
	}
	
	public func delete(record: SObject, options: Options = []) -> Promise<Void> {
		guard let id = record.id else {
			return Promise(error: Salesforce.Error.invalidArgument(name: "record", value: nil, message: "Record ID can't be nil."))
		}
		return delete(type: record.type, id: id)
	}
	
	// MARK: - Describe methods
	
	/// Asynchronously retrieves metadata about a Salesforce object and its fields.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm
	/// - Parameter type: Object name
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise<ObjectDescription>
	public func describe(type: String, options: Options = []) -> Promise<ObjectDescription> {
		let resource = SObjectResource.describe(type: type, version: config.version)
		return dataTask(with: resource, options: options)
	}
	
	/// Asynchronously retrieves metadata for multiple Salesforce objects.
	/// - Parameter types: Array of object types (e.g. "Account")
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise<[ObjectDescription]>, a promise of an array of ObjectDescriptions, in the same order as the "types" parameter.
	public func describe(types: [String], options: Options = []) -> Promise<[ObjectDescription]> {
		let promises = types.map { describe(type: $0) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously retrieves object-level metadata about all objects defined in the org.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_describeGlobal.htm
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of an array of ObjectDescriptions
	public func describeAll(options: Options = []) -> Promise<[ObjectDescription]> {
		let resource = SObjectResource.describeGlobal(version: config.version)
		return dataTask(with: resource, options: options).map { (result: DescribeAllResult) -> [ObjectDescription] in
			return result.sobjects
		}
	}
	
	// MARK: - Register for push notifications
	
	/// Use this method to register your device to receive push notifications from the Salesforce Universal Push Notification service.
	/// - Parameter deviceToken: Device token returned from a successful UIApplication.shared.registerForRemoteNotifications() invocation.
	/// - Parameter options: If you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a String which holds the ID of the newly-inserted MobilePushServiceDevice record
	public func registerForNotifications(deviceToken: String, options: Options = []) -> Promise<String> {
		return firstly { () -> Promise<InsertResult> in
			let resource = SObjectResource.registerForNotifications(deviceToken: deviceToken, version: config.version)
			return dataTask(with: resource, options: options)
		}.map { $0.id }
	}
}

// MARK: - Internal-use, decodable models
fileprivate extension Salesforce {
	
	fileprivate struct InsertResult: Decodable {
		var id: String
	}
	
	fileprivate struct DescribeAllResult: Decodable {
		var sobjects: [ObjectDescription]
	}
}
