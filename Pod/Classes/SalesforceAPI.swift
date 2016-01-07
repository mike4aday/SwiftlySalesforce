//
//  SalesforceAPI.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import Alamofire


public enum SalesforceAPI {
	
	public typealias Route = (method: Alamofire.Method, URI: String, parameters: [String: AnyObject]?, headers: [String: String]?)

	static public let DefaultVersion: Float = 35.0
	
	case Identity

	case Limits
	
	case Query(soql: String)
	case NextQueryResult(path: String)
	
	case CreateRecord(type: String, fields: [String: AnyObject])
	case ReadRecord(type: String, id: String, fields: [String]?)
	case UpdateRecord(type: String, id: String, fields: [String: AnyObject])
	case DeleteRecord(type: String, id: String)
		
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
				URI: "/sobjects/\(type)/\(id)/",
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
		}
	}
	
	/// Creates an 'endpoint' for the enum member
	/// - Parameter credentials: Credentials instance with access token, refresh token, etc.
	/// - Parameter version: Version of the Salesforce REST API.
	/// - Returns: NSMutableURLRequest which can be used by Alamofire manager instance to make asynchronous REST API request
	public func endpoint(credentials credentials: Credentials, version: Float = DefaultVersion) -> NSMutableURLRequest {
		
		let route = self.route
		
		// Base URL
		var URL: NSURL
		switch self {
		case .Identity:
			URL = credentials.identityURL
		case .NextQueryResult:
			URL = credentials.instanceURL.URLByAppendingPathComponent(route.URI)
		default:
			URL = credentials.instanceURL.URLByAppendingPathComponent("/services/data/v\(version)\(route.URI)")
		}
		
		let req = NSMutableURLRequest(URL: URL)
		
		// Method
		req.HTTPMethod = route.method.rawValue
		
		// Headers
		req.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
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
	
	/// Creates an 'endpoint' for the enum member
	/// - Parameter credentials: Credentials instance with access token, refresh token, etc. Optional.
	/// - Parameter version: Version of the Salesforce REST API. 
	/// - Returns: NSMutableURLRequest which can be used by Alamofire manager instance to make asynchronous REST API request
	/// - Throws: Error if the credentials are nil (for example, if the user hasn't authenticated yet)
	public func endpoint(credentials credentials: Credentials? = AuthenticationManager.sharedInstance.credentials, version: Float = DefaultVersion) throws -> NSMutableURLRequest {
		
		guard let creds = credentials else {
			// User hasn't authenticated; no credentials available
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUserAuthenticationRequired, userInfo: nil)
		}
		
		return self.endpoint(credentials: creds, version: version)
	}
}