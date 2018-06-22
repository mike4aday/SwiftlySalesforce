//
//  Salesforce+Query.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import PromiseKit

public extension Salesforce {

	//MARK: - Query methods
	
	public func query<T: Decodable>(soql: String, batchSize: Int? = nil, options: Options = []) -> Promise<QueryResult<T>> {
		let resource = RESTResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	public func query(soql: String, batchSize: Int? = nil, options: Options = []) -> Promise<QueryResult<Record>> {
		let resource = RESTResource.query(soql: soql, batchSize: batchSize, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	public func query<T: Decodable>(soql: [String], batchSize: Int? = nil, options: Options = []) -> Promise<[QueryResult<T>]> {
		let promises: [Promise<QueryResult<T>>] = soql.map { query(soql: $0, batchSize: batchSize, options: options) }
		return when(fulfilled: promises)
	}
	
	public func query(soql: [String], batchSize: Int? = nil, options: Options = []) -> Promise<[QueryResult<Record>]> {
		let promises: [Promise<QueryResult<Record>>] = soql.map { query(soql: $0, batchSize: batchSize, options: options) }
		return when(fulfilled: promises)
	}
	
	public func queryNext<T: Decodable>(path: String, options: Options = []) -> Promise<QueryResult<T>> {
		let resource = RESTResource.queryNext(path: path)
		return dataTask(resource: resource, options: options)
	}
	
	public func queryNext(path: String, options: Options = []) -> Promise<QueryResult<Record>> {
		let resource = RESTResource.queryNext(path: path)
		return dataTask(resource: resource, options: options)
	}
	
	// MARK: - Search
	
	public func search(sosl: String, options: Options = []) -> Promise<SearchResult> {
		let resource = RESTResource.search(sosl: sosl, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	//MARK: - Retrieve methods
	
	/// Asynchronously retrieves a single record.
	/// - Parameter type: The type of the record, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter id: ID of the record to retrieve
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of a Decodable instance
	public func retrieve<T: Decodable>(type: String, id: String, fields: [String]? = nil, options: Options = []) -> Promise<T> {
		let resource = RESTResource.retrieve(type: type, id: id, fields: fields, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	/// Asynchronously retrieves a single record (non-generic function version).
	/// - Parameter type: The type of the record, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter id: ID of the record to retrieve
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of a Record instance
	public func retrieve(type: String, id: String, fields: [String]? = nil, options: Options = []) -> Promise<Record> {
		let resource = RESTResource.retrieve(type: type, id: id, fields: fields, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	/// Asynchronously retrieves multiple records of the same type, by ID.
	/// - Parameter type: The type of the records to retrieve, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter ids: IDs of the records to retrieve. All records must be of the same type.
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of an array of Decodable instances
	public func retrieve<T: Decodable>(type: String, ids: [String], fields: [String]? = nil, options: Options = []) -> Promise<[T]> {
		let promises: [Promise<T>] = ids.map { retrieve(type: type, id: $0, fields: fields) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously retrieves multiple records of the same type, by ID (non-generic version).
	/// - Parameter type: The type of the records to retrieve, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter ids: IDs of the records to retrieve. All records must be of the same type.
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of an array of Record instances in the same order as the "ids" parameter
	public func retrieve(type: String, ids: [String], fields: [String]? = nil, options: Options = []) -> Promise<[Record]> {
		let promises: [Promise<Record>] = ids.map { retrieve(type: type, id: $0, fields: fields) }
		return when(fulfilled: promises)
	}
	
	// MARK: - Insert methods
	
	/// Asynchronously creates a new record in Salesforce
	/// - Parameter type: The type of the record to be inserted, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter record: an Encodable object that will be inserted as a new record in Salesforce
	/// - Returns: Promise of a string which holds the ID of the newly-inserted record
	public func insert<T: Encodable>(type: String, record: T, options: Options = []) -> Promise<String> {
		return firstly { () -> Promise<InsertResult> in
			let data = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(record)
			let resource = RESTResource.insert(type: type, data: data, version: configuration.version)
			return dataTask(resource: resource, options: options)
		}.map { $0.id }
	}
	
	/// Ansynchronously creates a new record in Salesforce
	public func insert(record: Record, options: Options = []) -> Promise<String> {
		return insert(type: record.type, record: record)
	}
	
	/// Asynchronously creates a new record in Salesforce
	/// - Parameter type: The type of the record to be inserted, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter fields: Dictionary of field names and values to be set on the newly-inserted record.
	/// - Returns: Promise of a string which holds the ID of the newly-inserted record
	public func insert(type: String, fields: [String: Encodable?], options: Options = []) -> Promise<String> {
		let record = Record(type: type, fields: fields)
		return insert(type: type, record: record)
	}
	
	// MARK: - Update methods
	
	/// Asynchronously updates a record in Salesforce
	/// - Parameter type: Type of record to be updated (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be updated
	/// - Parameter record: record with updates (record should not encode an "Id" property, or other non-updateable fields)
	/// - Returns: Promise<Void>
	public func update<T: Encodable>(type: String, id: String, record: T, options: Options = []) -> Promise<Void> {
		return firstly { () -> Promise<DataResponse> in
			let data = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(record)
			let resource = RESTResource.update(type: type, id: id, data: data, version: configuration.version)
			return dataTask(resource: resource, options: options)
		}.done { _ in return }
	}
	
	/// Asynchronously updates a record in Salesforce
	public func update(record: Record, options: Options = []) -> Promise<Void> {
		guard let id = record.id else {
			return Promise(error: Salesforce.Error.invalidArgument(name: "record", value: nil, message: "Record ID can't be nil."))
		}
		return update(type: record.type, id: id, record: record)
	}
	
	/// Asynchronously updates a record in Salesforce
	/// - Parameter type: Type of record to be updated (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be updated
	/// - Parameter fields: Dictionary of updated field name and value pairs.
	/// - Returns: Promise<Void>
	public func update(type: String, id: String, fields: [String: Encodable?], options: Options = []) -> Promise<Void> {
		let record = Record(type: type, fields: fields)
		return update(type: type, id: id, record: record)
	}
	
	// MARK: - Delete methods
	
	/// Asynchronously deletes a record
	/// - Parameter type: Type of record to be deleted (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be deleted
	/// - Returns: Promise<Void>
	public func delete(type: String, id: String, options: Options = []) -> Promise<Void> {
		let resource = RESTResource.delete(type: type, id: id, version: configuration.version)
		return dataTask(resource: resource, options: options).done { _ in return }
	}
	
	public func delete(record: Record, options: Options = []) -> Promise<Void> {
		guard let id = record.id else {
			return Promise(error: Salesforce.Error.invalidArgument(name: "record", value: nil, message: "Record ID can't be nil."))
		}
		return delete(type: record.type, id: id)
	}
	
	// MARK: - Describe methods
	
	/// Asynchronously retrieves metadata about a Salesforce object and its fields.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm
	/// - Parameter type: Object name
	/// - Returns: Promise<ObjectDescription>
	public func describe(type: String, options: Options = []) -> Promise<ObjectMetadata> {
		let resource = RESTResource.describe(type: type, version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	/// Asynchronously retrieves metadata for multiple Salesforce objects.
	/// - Parameter types: Array of object names
	/// - Returns: Promise<[ObjectDescription]>, a promise of an array of ObjectDescriptions, in the same order as the "types" parameter.
	public func describe(types: [String], options: Options = []) -> Promise<[ObjectMetadata]> {
		let promises = types.map { describe(type: $0) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously retrieves object-level metadata about all objects defined in the org.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_describeGlobal.htm
	/// - Returns: Promise of an array of ObjectDescriptions
	public func describeAll(options: Options = []) -> Promise<[ObjectMetadata]> {
		let resource = RESTResource.describeGlobal(version: configuration.version)
		return dataTask(resource: resource, options: options).map { (result: DescribeAllResult) -> [ObjectMetadata] in
			return result.sobjects
		}
	}
	
	// MARK: - Image methods
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. images at Account.PhotoUrl, Contact.PhotoUrl, or Lead.PhotoUrl.
	/// - Parameter path: path relative to the user's instance URL
	/// - Returns: Promise of an image
	public func fetchImage(path: String, options: Options = []) -> Promise<UIImage> {
		let resource = RESTResource.fetchFile(baseURL: nil, path: path, accept: URLRequest.MIMEType.anyImage.description)
		let bgq = DispatchQueue.global(qos: .userInitiated)
		return dataTask(resource: resource, options: options).compactMap(on: bgq) { (result: DataResponse) -> UIImage? in
			UIImage(data: result.data)
		}
	}
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. User.SmallPhotoUrl or User.FullPhotoUrl.
	/// - Parameter url: URL to the image to be retrieved
	/// - Returns: Promise of an image
	public func fetchImage(url: URL, options: Options = []) -> Promise<UIImage> {
		let resource = RESTResource.fetchFile(baseURL: url, path: nil, accept: URLRequest.MIMEType.anyImage.description)
		let bgq = DispatchQueue.global(qos: .userInitiated)
		return dataTask(resource: resource, options: options).compactMap(on: bgq) { (result: DataResponse) -> UIImage? in
			UIImage(data: result.data)
		}
	}
	
	// MARK: - Miscellaneous

	/// Asynchronously requests information about the current user
	/// See https://help.salesforce.com/articleView?id=remoteaccess_using_openid.htm&type=0
	public func identity(options: Options = []) -> Promise<Identity> {
		let resource = RESTResource.identity(version: configuration.version)
		let validator: DataResponseValidator = {
			if let httpResp = $0.response as? HTTPURLResponse, httpResp.statusCode == 403 {
				throw Salesforce.Error.unauthorized
			}
			return try Promise.defaultValidator($0)
		}
		return dataTask(resource: resource, options: options, validator: validator)
	}
	
	/// Asynchronously retrieves information about the Salesforce organization ("org")
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_organization.htm
	public func organization(options: Options = []) -> Promise<Organization> {
		return identity(options: options).then {
			self.retrieve(type: "Organization", id: $0.orgID)
		}
	}
	
	/// Asynchronously retrieves information about org limits
	/// - Returns: Promise of a dictionary of Limits, keyed by limit name
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
	public func limits(options: Options = []) -> Promise<[String:Limit]> {
		let resource = RESTResource.limits(version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	/// Use this method to register your device to receive push notifications from the Salesforce Universal Push Notification service.
	/// - Parameter devicetoken: the device token returned from a successful UIApplication.shared.registerForRemoteNotification() invocation.
	/// - Returns: Promise of a String which holds the ID of the newly-inserted MobilePushServiceDevice record
	public func registerForNotifications(deviceToken: String, options: Options = []) -> Promise<String> {
		return firstly { () -> Promise<InsertResult> in
			let resource = RESTResource.registerForNotifications(deviceToken: deviceToken, version: configuration.version)
			return dataTask(resource: resource, options: options)
		}.map { $0.id }
	}
	
	// MARK: - Apex web services
	
	/// Asynchronously calls an Apex method exposed as a REST endpoint.
	/// See https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST
	/// - Parameter method: HTTP method
	/// - Parameter path: String that gets appended to instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of query string parameters
	/// - Parameter body: Data to be sent in the body of the request, e.g. JSON as Data in the body of a POST request
	/// - Parameter contentType: the MIME type of the request content
	/// - Parameter headers: Dictionary of custom HTTP header values
	/// - Returns: Promise of Data
	public func apex(
		method: URLRequest.HTTPMethod = .get,
		path: String,
		parameters: [String: Any?]? = nil,
		body: Data? = nil,
		contentType: String? = nil,
		headers: [String: String]? = nil,
		options: Options = []) -> Promise<Data> {
		
		let ct = contentType ?? ( method == .get || method == .delete ? URLRequest.MIMEType.urlEncoded : URLRequest.MIMEType.json).description
		let params: [String: String]? = parameters?.mapValues { "\($0 ?? "")" }
		let resource = RESTResource.apex(method: method, path: path, queryParameters: params, body: body, contentType: ct, headers: headers)
		return dataTask(resource: resource, options: options).map { $0.data }
	}
	
	// MARK: - Custom
	
	/// Use this method to call a Salesforce REST API endpoint that's not covered by the other methods.
	/// Note: baseURL and path should not both be nil
	/// - Parameter method: HTTP method
	/// - Parameter baseURL: Base URL to which the path parameter will be appended. If nil, then user's "instance URL" will be used
	/// - Parameter path: Absolute path to endpoint, relative to "baseURL" parameter or, if "baseURL" is nil, then relative to the user's "instance URL"
	/// - Parameter parameters: Dictionary of query string parameters
	/// - Parameter body: Data to be sent in the body of the request, e.g. JSON as Data in the body of a POST request
	/// - Parameter contentType: the MIME type of the request content; defaults to "application/json"
	/// - Parameter headers: Dictionary of custom HTTP header values
	/// - Returns: Promise of Data
	public func custom(
		method: URLRequest.HTTPMethod = .get,
		baseURL: URL? = nil,
		path: String? = nil,
		parameters: [String: Any?]? = nil,
		body: Data? = nil,
		contentType: String = URLRequest.MIMEType.json.description,
		headers: [String: String]? = nil,
		options: Options = []) -> Promise<Data> {
		
		let params: [String: String]? = parameters?.mapValues { "\($0 ?? "")" }
		let resource = RESTResource.custom(method: method, baseURL: baseURL, path: path, queryParameters: params, body: body, contentType: contentType, headers: headers)
		return dataTask(resource: resource, options: options).map { $0.data }
	}
}

// MARK: - Internal-use, decodable models
fileprivate extension Salesforce {
	
	fileprivate struct InsertResult: Decodable {
		var id: String
	}
	
	fileprivate struct DescribeAllResult: Decodable {
		var sobjects: [ObjectMetadata]
	}
}
