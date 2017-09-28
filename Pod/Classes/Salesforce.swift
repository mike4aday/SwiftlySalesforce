//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Salesforce API

import Foundation
import PromiseKit

open class Salesforce {

	/// Default Salesforce API version
	static public let defaultVersion = "40.0" // Summer '17

	private let q = DispatchQueue.global(qos: .userInitiated)
	
	public var connectedApp: ConnectedApp
	public var version: String
	
	private var requestor: DataRequestor
	
	public init(connectedApp: ConnectedApp, version: String = Salesforce.defaultVersion) {
		self.connectedApp = connectedApp
		self.version = version
		self.requestor = DataRequestor(connectedApp: connectedApp)
	}
	
	/// Asynchronously requests information about the current user
	/// See https://help.salesforce.com/articleView?id=remoteaccess_using_openid.htm&type=0
	open func identity() -> Promise<Identity> {
		let handler: DataRequestor.ResponseHandler = {
			(data, response, error) throws -> Data in
			guard let resp = response as? HTTPURLResponse, resp.statusCode != 403 else {
				throw SalesforceError.userAuthenticationRequired
			}
			return try DataRequestor.defaultResponseHandler(data, response, error)
		}
		return requestor.request(resource: .identity(version: version), responseHandler: handler).asJSON().then(on: q) {
			(json: [String: Any]) -> Identity in
			return try Identity(json: json)
		}
	}
	
	/// Asynchronously retrieves information about org limits
	/// - Returns: Promise of an array of Limits
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
	open func limits() -> Promise<[Limit]> {
		return requestor.request(resource: .limits(version: version)).asJSON().then(on: q) {
			(result: [String: Any]) -> [Limit] in
			guard let json = result as? [String: [String: Any]] else {
				throw SerializationError.invalid(result, message: "Unable to parse limit information")
			}
			return json.flatMap { try? Limit(name: $0, json: $1) }
		}
	}
	
	/// Asynchronsouly executes a SOQL query.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Returns: Promise of a QueryResult
	open func query(soql: String) -> Promise<QueryResult> {
		return requestor.request(resource: .query(soql: soql, version: version)).asJSON().then(on: q) {
			(json: [String: Any]) -> QueryResult in
			return try QueryResult(json: json)
		}
	}
	
	/// Asynchronsouly executes multiple SOQL queries.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: Array of SOQL queries
	/// - Returns: Promise of an array of QueryResults, in the same order as the "soql" parameter
	open func query(soql: [String]) -> Promise<[QueryResult]> {
		let promises = soql.map { query(soql: $0) }
		return when(fulfilled: promises)
	}
	
	/// Queries next batch of records returned by a SOQL query whose result is broken into multiple batches (i.e. paginated).
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter path: the 'nextRecordsPath' property of a previously-obtained QueryResult.
	/// - Returns: Promise of a QueryResult
	open func queryNext(path: String) -> Promise<QueryResult> {
		return requestor.request(resource: .queryNext(path: path)).asJSON().then(on: q) {
			(json: [String: Any]) -> QueryResult in
			return try QueryResult(json: json)
		}
	}
	
	/// Asynchronously retrieves a single record
	/// - Parameter type: The type of the record, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter id: ID of the record to retrieve
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of a dictionary keyed by field names (aka "Record")
	open func retrieve(type: String, id: String, fields: [String]? = nil) -> Promise<Record> {
		return requestor.request(resource: .retrieve(type: type, id: id, fields: fields, version: version)).asJSON()
	}
	
	/// Asynchronously retrieves multiple records of the same type, by ID
	/// - Parameter type: The type of the records to retrieve, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter ids: IDs of the records to retrieve. All records must be of the same type.
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of an array of dictionaries, keyed by field names, and in the same order as the "ids" parameter
	open func retrieve(type: String, ids: [String], fields: [String]? = nil) -> Promise<[Record]> {
		let promises = ids.map { retrieve(type: type, id: $0, fields: fields) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously creates a new record
	/// - Parameter type: The type of the record to be inserted, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter fields: Dictionary of field names and values to be set on the newly-inserted record.
	/// - Returns: Promise of a string which holds the ID of the newly-inserted record
	open func insert(type: String, fields: [String: Any]) -> Promise<String> {
		return requestor.request(resource: .insert(type: type, fields: fields, version: version)).asString()
	}
	
	/// Asynchronously updates a record
	/// - Parameter type: Type of record to be updated (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be updated
	/// - Parameter fields: Dictionary of field name and field value pairs.
	/// - Returns: Promise<Void>
	open func update(type: String, id: String, fields: [String: Any]) -> Promise<Void> {
		return requestor.request(resource: .update(type: type, id: id, fields: fields, version: version)).asVoid()
	}
	
	/// Asynchronously deletes a record
	/// - Parameter type: Type of record to be deleted (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be deleted
	/// - Returns: Promise<Void>
	open func delete(type: String, id: String) -> Promise<Void> {
		return requestor.request(resource: .delete(type: type, id: id, version: version)).asVoid()
	}
	
	/// Asynchronously retrieves metadata about a Salesforce object and its fields.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm
	/// - Parameter type: Object name
	/// - Returns: Promise<ObjectDescription>
	open func describe(type: String) -> Promise<ObjectDescription> {
		return requestor.request(resource: .describe(type: type, version: version)).asJSON().then(on: q) {
			(json: [String: Any]) -> ObjectDescription in
			return try ObjectDescription(json: json)
		}
	}
	
	/// Asynchronously retrieves metadata for multiple Salesforce objects.
	/// - Parameter types: Array of object names
	/// - Returns: Promise<[ObjectDescription]>, a promise of an array of ObjectDescriptions, in the same order as the "types" parameter.
	open func describe(types: [String]) -> Promise<[ObjectDescription]> {
		let promises = types.map { describe(type: $0) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously retrieves object-level metadata about all objects defined in the org.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_describeGlobal.htm
	/// - Returns: Promise of a dictionary of ObjectDescriptions, keyed by object name
	open func describeAll() -> Promise<[String: ObjectDescription]> {
		return requestor.request(resource: .describeGlobal(version: version)).asJSON().then(on: q) {
			(result: [String: Any]) -> [String: ObjectDescription] in
			guard let jsonArray = result["sobjects"] as? [[String: Any]] else {
				throw SerializationError.invalid(result, message: "Unable to parse describe all result")
			}
			var dict = Dictionary<String, ObjectDescription>()
			for json in jsonArray {
				if let name = json["name"] as? String {
					dict[name] = try ObjectDescription(json: json)
				}
			}
			return dict
		}
	}
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. images at Account.PhotoUrl, Contact.PhotoUrl, or Lead.PhotoUrl.
	/// - Parameter path: path relative to the user's instance URL
	/// - Returns: Promise of an image
	open func fetchImage(path: String) -> Promise<UIImage> {
		return requestor.request(resource: .custom(method: .get, baseURL: nil, path: path, parameters: nil, headers: ["Accept": "image/*"])).asImage(on: q)
	}
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. User.SmallPhotoUrl or User.FullPhotoUrl.
	/// - Parameter url: URL to the image to be retrieved
	/// - Returns: Promise of an image
	open func fetchImage(url: URL) -> Promise<UIImage> {
		return requestor.request(resource: .custom(method: .get, baseURL: url, path: nil, parameters: nil, headers: ["Accept": "image/*"])).asImage(on: q)
	}
	
	/// Use this method to register your device to receive push notifications from the Salesforce Universal Push Notification service.
	/// - Parameter devicetoken: the device token returned from a successful UIApplication.shared.registerForRemoteNotification() invocation.
	/// - Returns: Promise of JSON dictionary containing successful registration information
	open func registerForNotifications(deviceToken: String) -> Promise<[String: Any]> {
		return requestor.request(resource: .registerForNotifications(deviceToken: deviceToken, version: version)).asJSON()
	}
		
	/// Asynchronously calls an Apex method exposed as a REST endpoint.
	/// See https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST
	/// The endpoint's response should be JSON-formatted.
	/// - Parameter method: HTTP method
	/// - Parameter path: String that gets appended to instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of parameter name/value pairs
	/// - Parameter headers: Dictionary of HTTP header values
	/// - Returns: Promise of Data
	open func apex(method: HTTPMethod = .get, path: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Promise<Data> {
		return requestor.request(resource: .apex(method: method, path: path, parameters: parameters, headers: headers))
	}

	/// Use this method to call a Salesforce REST API endpoint that's not covered by the other methods.
	/// Note: baseURL and path should not both be nil
	/// - Parameter method: HTTP method
	/// - Parameter baseURL: Base URL to which the path parameter will be appended. If nil, then user's "instance URL" will be used
	/// - Parameter path: Absolute path to endpoint, relative to "baseURL" parameter or, if "baseURL" is nil, then relative to the user's "instance URL"
	/// - Parameter parameters: Dictionary of parameter name/value pairs
	/// - Parameter headers: Dictionary of HTTP header values
	/// - Returns: Promise of Data
	open func custom(method: HTTPMethod = .get, baseURL: URL? = nil, path: String? = nil, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Promise<Data> {
		return requestor.request(resource: .custom(method: method, baseURL: baseURL, path: path, parameters: parameters, headers: headers))
	}
}
