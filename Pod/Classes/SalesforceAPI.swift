//
//  SalesforceAPI.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit


public enum SalesforceAPI {
	
	case Identity

	case Limits
	
	case Query(soql: String)
	
	/// Next page of records in a query result.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter: Path, value of 'nextRecordsUrl' in JSON query result
	case NextQueryResult(path: String)
	
	case CreateRecord(type: String, fields: [String: AnyObject])
	case ReadRecord(type: String, id: String, fields: [String]?)
	case UpdateRecord(type: String, id: String, fields: [String: AnyObject])
	case DeleteRecord(type: String, id: String)
	
	case ApexRest(method: Alamofire.Method, path: String, parameters: [String: AnyObject]?, headers: [String: String]?)
	
	case Custom(method: Alamofire.Method, path: String, parameters: [String: AnyObject]?, headers: [String: String]?)
}


// MARK: - Extension
extension SalesforceAPI {
	
	public typealias Route = (method: Alamofire.Method, URI: String, parameters: [String: AnyObject]?, headers: [String: String]?)
	
	static public let DefaultVersion: Float = 36.0

	var route: Route {
		
		switch self {
		case .Identity:
			return (
				method: .GET,
				URI: "",
				parameters: nil,
				headers: nil
			)
		case .Limits:
			return (
				method: .GET,
				URI: "/limits/",
				parameters: nil,
				headers: nil
			)
		case let .Query(soql):
			return (
				method: .GET,
				URI: "/query/",
				parameters: ["q": soql],
				headers: nil
			)
		case let .NextQueryResult(path):
			return (
				method: .GET,
				URI: path,
				parameters: nil,
				headers: nil
			)
		case let CreateRecord(type, record):
			return (
				method: .POST,
				URI: "/sobjects/\(type)/",
				parameters: record,
				headers: nil
			)
		case let ReadRecord(type, id, fields):
			return (
				method: .GET,
				URI: "/sobjects/\(type)/\(id)",
				parameters: ["fields": (fields?.joinWithSeparator(","))!],
				headers: nil
			)
		case let UpdateRecord(type, id, record):
			return (
				method: .PATCH,
				URI: "/sobjects/\(type)/\(id)/",
				parameters: record,
				headers: nil
			)
		case let DeleteRecord(type, id):
			return (
				method: .DELETE,
				URI: "/sobjects/\(type)/\(id)/",
				parameters: nil,
				headers: nil
			)
		case let ApexRest(method, path, parameters, headers):
			return (
				method: method,
				URI: path,
				parameters: parameters,
				headers: headers
			)
		case let Custom(method, path, parameters, headers):
			return (
				method: method,
				URI: path,
				parameters: parameters,
				headers: headers
			)
		}
	}
	
	/// Makes an asynchronous request for Salesforce data. Typically, this will be the
	/// only method of this enum that callers will use.
	/// - Parameter version: Salesforce API version (irrelevant for custom resources, e.g. Apex REST)
	/// - Returns: Promise of Salesforce data in JSON format
	public func request(version version: Float = DefaultVersion) -> Promise<AnyObject> {
		
		return Promise<Credentials>  {
			
			fullfill, reject in
			
			if let credentials = OAuth2Manager.sharedInstance.credentials {
				// Use credentials we already have
				fullfill(credentials)
			}
			else {
				// We don't have any credentials; user authentication is required
				reject(NSError(domain: NSURLErrorDomain, code: NSURLError.UserAuthenticationRequired.rawValue, userInfo: nil))
			}
		}.then {
			(credentials) -> Promise<AnyObject> in
			return self.request(credentials: credentials, version: version)
		}.recover {
			(error) -> Promise<AnyObject> in
			if let err = error as NSError? where err.isAuthenticationRequiredError() {
				return OAuth2Manager.sharedInstance.authorize().then {
					(credentials) -> Promise<AnyObject> in
					return self.request(credentials: credentials, version: version)
				}
			}
			else {
				throw error
			}
		}
	}
	
	public func request(credentials credentials: Credentials, manager: Manager = Manager.sharedInstance, version: Float = DefaultVersion) -> Promise<AnyObject> {
		
		return Promise {
			fulfill, reject in
			manager.request(self.endpoint(credentials: credentials, version: version))
			.validateSalesforceResponse()
			.responseJSON {
				(response) -> () in
				switch response.result {
				case .Success(let json):
					fulfill(json)
				case .Failure(let error):
					reject(error)
				}
			}
		}
	}
	
	/// Creates an 'endpoint' for the enum member
	/// - Parameter credentials: Credentials instance with access token, refresh token, etc.
	/// - Parameter version: Version of the Salesforce REST API.
	/// - Returns: Complete NSMutableURLRequest which can be used by Alamofire manager instance to make an asynchronous REST API request
	public func endpoint(credentials credentials: Credentials, version: Float = DefaultVersion) -> NSMutableURLRequest {
		
		let route = self.route 
		
		// Base URL
		var URL: NSURL
		switch self {
		case .Identity:
			URL = credentials.identityURL
		case .NextQueryResult, .Custom:
			URL = credentials.instanceURL.URLByAppendingPathComponent(route.URI)
		case .ApexRest:
			URL = credentials.instanceURL.URLByAppendingPathComponent("/services/apexrest\(route.URI)")
		default:
			URL = credentials.instanceURL.URLByAppendingPathComponent("/services/data/v\(version)\(route.URI)")
		}
		
		let req = NSMutableURLRequest(URL: URL)
		
		// Method
		req.HTTPMethod = route.method.rawValue
		
		// Headers
		req.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		if let headers = route.headers {
			for (key, value) in headers {
				req.setValue(value, forHTTPHeaderField: key)
			}
		}
		
		// Parameter encoding
		switch route.method {
		case .GET:
			// URL encoded parameters
			return ParameterEncoding.URL.encode(req, parameters: route.parameters).0
		default:
			// JSON encoded parameters
			if let params = route.parameters {
				guard NSJSONSerialization.isValidJSONObject(params) else {
					// Shouldn't get here! If we did, then parameters can't be converted to JSON, and the app would crash,
					// so we don't encode parameters at all, likely leading to a HTTP request failure down the line
					// TODO: better way to handle this?
					NSLog("Invalid parameter(s), cannot be encoded as JSON: %@", params)
					return req
				}
				return ParameterEncoding.JSON.encode(req, parameters: params).0
			}
			else {
				return req
			}
		}
	}
}