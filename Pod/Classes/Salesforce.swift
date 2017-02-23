//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit
import Alamofire

open class Salesforce {
	
	open static let shared = Salesforce()
	open static let defaultVersion = "38.0" // Winter '17
	
	open let authManager = AuthManager()
	open var version = Salesforce.defaultVersion
	
	fileprivate init() {
		// Can't instantiate
	}
	
	/// Asynchronously requests information about the current user
	/// See https://help.salesforce.com/articleView?id=remoteaccess_using_openid.htm&type=0
	open func identity() -> Promise<UserInfo> {
		let builder = {
			authData in
			return try Router.identity(authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> UserInfo in
			return UserInfo(json: response)
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronously retrieves information about org limits
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
	open func limits() -> Promise<[Limit]> {
		let builder = {
			authData in
			return try Router.limits(authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: [String: Int]]) throws -> [Limit] in
			var limits = [Limit]()
			for (name, value) in response {
				try limits.append(Limit(name: name, json: value))
			}
			return limits
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronsouly executes a SOQL query.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm
	/// - Parameter soql: SOQL query
	/// - Returns: Promise of a QueryResult
	open func query(soql: String) -> Promise<QueryResult> {
		let builder = {
			authData in
			return try Router.query(soql: soql, authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> QueryResult in
			return try QueryResult(json: response)
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
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
		let builder = {
			authData in
			return try Router.queryNext(path: path, authData: authData).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> QueryResult in
			return try QueryResult(json: response)
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronously retrieves a single record 
	/// - Parameter type: The type of the record, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter id: ID of the record to retrieve
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of a dictionary keyed by field names
	open func retrieve(type: String, id: String, fields: [String]? = nil) -> Promise<[String: Any]> {
		let builder = {
			authData in
			return try Router.retrieve(type: type, id: id, fields: fields, authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> [String: Any] in
			return response
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronously retrieves multiple records of the same type, by ID
	/// - Parameter type: The type of the records to retrieve, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter ids: IDs of the records to retrieve. All records must be of the same type.
	/// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
	/// - Returns: Promise of an array of dictionaries, keyed by field names, and in the same order as the "ids" parameter
	open func retrieve(type: String, ids: [String], fields: [String]? = nil) -> Promise<[[String: Any]]> {
		let promises = ids.map { retrieve(type: type, id: $0, fields: fields) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously inserts a new record
	/// - Parameter type: The type of the record to be inserted, e.g. "Account", "Contact" or "MyCustomObject__c"
	/// - Parameter fields: Dictionary of field names and values to be set on the newly-inserted record.
	/// - Returns: Promise of a string which holds the ID of the newly-inserted record
	open func insert(type: String, fields: [String: Any]) -> Promise<String> {
		let builder = {
			(authData: AuthData) throws -> URLRequest in
			return try Router.insert(type: type, fields: fields, authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> String in
			guard let id = response["id"] as? String else {
				throw SalesforceError.jsonDeserializationFailure(elementName: "id", json: response)
			}
			return id
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	@available(*, deprecated: 3.1.1, message: "Parameter 'id' is not needed. Call insert(type: String, fields: [String: Any]) instead.")
	open func insert(type: String, id: String, fields: [String: Any]) -> Promise<String> {
		return insert(type: type, fields: fields)
	}
	
	/// Asynchronously updates a record
	/// - Parameter type: Type of record to be updated (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be updated
	/// - Parameter fields: Dictionary of field name and field value pairs.
	/// - Returns: Promise<Void>
	open func update(type: String, id: String, fields: [String: Any]) -> Promise<Void> {
		let builder = {
			(authData: AuthData) throws -> URLRequest in
			return try Router.update(type: type, id: id, fields: fields, authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(_: Any) -> () in
			return
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronously deletes a record
	/// - Parameter type: Type of record to be deleted (for example, "Account" or "Lead")
	/// - Parameter id: Unique ID of record to be deleted
	/// - Returns: Promise<Void>
	open func delete(type: String, id: String) -> Promise<Void> {
		let builder = {
			(authData: AuthData) throws -> URLRequest in
			return try Router.delete(type: type, id: id, authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(_: Any) -> () in
			return
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronously retrieves metadata information about a Salesforce object and its fields.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm
	/// - Parameter type: Object name
	/// - Returns: Promise<ObjectDescription>
	open func describe(type: String) -> Promise<ObjectDescription> {
		let builder = {
			(authData: AuthData) throws -> URLRequest in
			return try Router.describe(type: type, authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> ObjectDescription in
			return ObjectDescription(json: response)
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Asynchronously retrieves metadata information for multiple Salesforce objects.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm
	/// - Parameter types: Array of object names
	/// - Returns: Promise<[ObjectDescription]>, a promise of an array of ObjectDescriptions, in the same order as the "types" parameter.
	open func describe(types: [String]) -> Promise<[ObjectDescription]> {
		let promises = types.map { describe(type: $0) }
		return when(fulfilled: promises)
	}
	
	/// Asynchronously calls an Apex method exposed as a REST endpoint.
	/// See https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST
	/// The endpoint's response should be JSON-formatted.
	/// - Parameter method: HTTP method
	/// - Parameter path: String that gets appended to instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of parameter name/value pairs
	/// - Parameter headers: Dictionary of HTTP header values
	/// - Returns: Promise of Any type; result should be JSON-formatted.
	open func apexRest(method: HTTPMethod = .get, path: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Promise<Any> {
		let builder = {
			authData in
			return try Router.apexREST(method: method, path: path, parameters: parameters, headers: headers, authData: authData).asURLRequest()
		}
		let deserializer = {
			(response: Any) throws -> Any in
			return response
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	/// Use this method to call a Salesforce REST API endpoint that's not covered by the other methods.
	/// - Parameter method: HTTP method
	/// - Parameter path: Absolute path to endpoint, but excluding instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of parameter name/value pairs
	/// - Parameter headers: Dictionary of HTTP header values
	/// - Returns: Promise of Any type; result should be JSON-formatted.
	open func custom(method: HTTPMethod = .get, path: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Promise<Any> {
		let builder = {
			authData in
			return try Router.custom(method: method, path: path, parameters: parameters, headers: headers, authData: authData).asURLRequest()
		}
		let deserializer = {
			(response: Any) throws -> Any in
			return response
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
    
    /// Use this method to register your device to receive push notifications from the Salesforce Universal Push Notification service
    /// - Parameter devicetoken: the device token returned from a successful UIApplication.shared.registerForRemoteNotification() invocation.
    /// - Returns: Promise of Any Type; result will either be success, or failure message
    open func registerForSalesforceNotifications(devicetoken: String) -> Promise<Any> {
        let headers = ["Content-Type" : "application/json"]
        let params = ["ConnectionToken" : devicetoken, "ServiceType" : "Apple" ]
        return custom(method: .post, path: "/services/data/v\(version)/sobjects/MobilePushServiceDevice", parameters: params, headers: headers)
    } 
    

	
	fileprivate func request<T,U>(requestBuilder: @escaping (AuthData) throws -> URLRequest, jsonDeserializer: @escaping (U) throws -> T) -> Promise<T> {
		
		return Promise<AuthData> {
			// Get credentials
			(fulfill, reject) -> () in
			if let authData = authManager.authData {
				// Use credentials we already have
				fulfill(authData)
			}
			else {
				reject(SalesforceError.userAuthenticationRequired)
			}
		}.then {
			// Send request
			(authData) -> Promise<T> in
			let urlRequest = try requestBuilder(authData)
			return self.send(urlRequest: urlRequest, jsonDeserializer: jsonDeserializer)
		}.recover {
			// Recover from expired session token error - fail on other errors
			(error) -> Promise<T> in
			if case SalesforceError.userAuthenticationRequired = error {
				return self.authManager.authorize().then {
					(authData) -> Promise<T> in
					let urlRequest = try requestBuilder(authData)
					return self.send(urlRequest: urlRequest, jsonDeserializer: jsonDeserializer)
				}
			}
			else {
				throw error
			}
		}
	}
	
	fileprivate func send<T,U>(urlRequest: URLRequest, jsonDeserializer: @escaping (U) throws -> T) -> Promise<T> {
		return Promise {
			fulfill, reject in
			Alamofire.request(urlRequest)
				.validate {
					(request, response, data) -> Request.ValidationResult in
					switch response.statusCode {
					case 401, 403:
						return .failure(SalesforceError.userAuthenticationRequired)
					case 400, 404, 405, 415:
						// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
						if let data = data,
							let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]],
							let firstError = json?[0],
							let errorCode = firstError["errorCode"] as? String,
							let message = firstError["message"] as? String {
							return .failure(SalesforceError.responseFailure(code: errorCode, message: message, fields: firstError["fields"] as? [String]))
						}
						else {
							return .failure(SalesforceError.responseFailure(code: "UNKNOWN_ERROR", message: "Unknown error. HTTP response status code: \(response.statusCode)", fields: nil))
						}
					case 500:
						return .failure(SalesforceError.serverFailure)
					default:
						return .success // The next .validate() call will catch other 4xx errors not caught above
					}
				}
				.validate()
				.responseJSON {
					(response) -> () in
					switch response.result {
					case .success(let json):
						do {
							guard let jsonAsU = json as? U else {
								throw SalesforceError.jsonDeserializationFailure(elementName: nil, json: json)
							}
							try fulfill(jsonDeserializer(jsonAsU))
						}
						catch {
							reject(error)
						}
					case .failure(let error):
						reject(error)
					}
			}
		}
	}
}
