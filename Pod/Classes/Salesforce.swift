//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit
import Alamofire

public let salesforce: Salesforce = Salesforce.shared

open class Salesforce {
	
	open static let shared = Salesforce()
	open static let defaultVersion = "38.0" // Winter '17
	
	open let authManager = AuthManager()
	open var version = Salesforce.defaultVersion
	
	fileprivate init() {
		// Can't instantiate
	}
	
	open func identity() -> Promise<UserInfo> {
		let builder = {
			authData in
			return try Router.identity(authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: Any]) throws -> UserInfo in
			return try UserInfo(json: response)
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
	open func limits() -> Promise<[Limit]> {
		let builder = {
			authData in
			return try Router.limits(authData: authData, version: self.version).asURLRequest()
		}
		let deserializer = {
			(response: [String: [String: Int]]) throws -> [Limit] in
			var limits = [Limit]()
			for (name, value) in response {
				guard let remaining = value["Remaining"], let maximum = value["Max"] else {
					throw SalesforceError.jsonDeserializationFailure(elementName: name, json: value)
				}
				limits.append(Limit(name: name, maximum: maximum, remaining: remaining))
			}
			return limits
		}
		return request(requestBuilder: builder, jsonDeserializer: deserializer)
	}
	
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
	
	open func insert(type: String, id: String, fields: [String: Any]) -> Promise<String> {
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
	
	/// Asynchronously updates a record
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
	
	/// Asynchronously calls an Apex method exposed as a REST endpoint.
	/// See https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST
	/// The current implementation expects that the endpoint's output will be JSON-formatted.
	/// - Parameter method: HTTP method
	/// - Parameter path: String that gets appended to instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of parameter name/value pairs
	/// - Parameter headers: Dictionary of HTTP header values
	/// - Returns: Promise of Any type
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
