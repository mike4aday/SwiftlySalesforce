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
	
	case identity

	case limits
	
	case query(soql: String)
	
	/// Next page of records in a query result.
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
	/// - Parameter: Path, value of 'nextRecordsUrl' in JSON query result
	case nextQueryResult(path: String)
	
	case createRecord(type: String, fields: [String: AnyObject])
	case readRecord(type: String, id: String, fields: [String]?)
	case updateRecord(type: String, id: String, fields: [String: AnyObject])
	case deleteRecord(type: String, id: String)
	
	case apexRest(method: Alamofire.HTTPMethod, path: String, parameters: [String: AnyObject]?, headers: [String: String]?)
	
	case custom(method: Alamofire.HTTPMethod, path: String, parameters: [String: AnyObject]?, headers: [String: String]?)
}


// MARK: - Extension
extension SalesforceAPI {
	
	public typealias Route = (method: Alamofire.HTTPMethod, URI: String, parameters: [String: AnyObject]?, headers: [String: String]?)
	
	static public let DefaultVersion: Float = 37.0

	var route: Route {
		
		switch self {
		case .identity:
			return (
				method: .get,
				URI: "",
				parameters: nil,
				headers: nil
			)
		case .limits:
			return (
				method: .get,
				URI: "/limits/",
				parameters: nil,
				headers: nil
			)
		case let .query(soql):
			return (
				method: .get,
				URI: "/query/",
				parameters: ["q": soql as AnyObject],
				headers: nil
			)
		case let .nextQueryResult(path):
			return (
				method: .get,
				URI: path,
				parameters: nil,
				headers: nil
			)
		case let .createRecord(type, record):
			return (
				method: .post,
				URI: "/sobjects/\(type)/",
				parameters: record,
				headers: nil
			)
		case let .readRecord(type, id, fields):
			return (
				method: .get,
				URI: "/sobjects/\(type)/\(id)",
				parameters: ["fields": (fields?.joined(separator: ","))! as AnyObject],
				headers: nil
			)
		case let .updateRecord(type, id, record):
			return (
				method: .patch,
				URI: "/sobjects/\(type)/\(id)/",
				parameters: record,
				headers: nil
			)
		case let .deleteRecord(type, id):
			return (
				method: .delete,
				URI: "/sobjects/\(type)/\(id)/",
				parameters: nil,
				headers: nil
			)
		case let .apexRest(method, path, parameters, headers):
			return (
				method: method,
				URI: path,
				parameters: parameters,
				headers: headers
			)
		case let .custom(method, path, parameters, headers):
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
	public func request(version: Float = DefaultVersion) -> Promise<AnyObject> {
		
		return Promise<Credentials>  {
			
			fullfill, reject in
			
			if let credentials = OAuth2Manager.sharedInstance.credentials {
				// Use credentials we already have
				fullfill(credentials)
			}
			else {
				// We don't have any credentials; user authentication is required
				reject(NSError(domain: NSURLErrorDomain, code: Foundation.URLError.userAuthenticationRequired.rawValue, userInfo: nil))
			}
		}.then {
			(credentials) -> Promise<AnyObject> in
			return self.request(credentials: credentials, version: version)
		}.recover {
			(error) -> Promise<AnyObject> in
			if let err = error as NSError? , err.isAuthenticationRequiredError() {
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
	
	public func request(credentials: Credentials, manager: SessionManager =  Alamofire.SessionManager.default, version: Float = DefaultVersion) -> Promise<AnyObject> {
		
		return Promise {
			fulfill, reject in
			manager.request(self.endpoint(credentials: credentials, version: version) as! URLRequestConvertible)
			.validateSalesforceResponse()
			.responseJSON {
				(response) -> () in
				switch response.result {
				case .success(let json):
					fulfill(json as AnyObject)
				case .failure(let error):
					reject(error)
				}
			}
		}
	}
	
	/// Creates an 'endpoint' for the enum member
	/// - Parameter credentials: Credentials instance with access token, refresh token, etc.
	/// - Parameter version: Version of the Salesforce REST API.
	/// - Returns: Complete NSMutableURLRequest which can be used by Alamofire manager instance to make an asynchronous REST API request
	public func endpoint(credentials: Credentials, version: Float = DefaultVersion) -> URLRequest {
		
		let route = self.route 
		
		// Base URL
		var URL: Foundation.URL
		switch self {
		case .identity:
			URL = credentials.identityURL as URL
		case .nextQueryResult, .custom:
			URL = credentials.instanceURL.appendingPathComponent(route.URI)
		case .apexRest:
			URL = credentials.instanceURL.appendingPathComponent("/services/apexrest\(route.URI)")
		default:
			URL = credentials.instanceURL.appendingPathComponent("/services/data/v\(version)\(route.URI)")
		}
		
		var req = URLRequest(url: URL)
        

		
		// Method
		req.httpMethod = route.method.rawValue
		
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
		case .get:
			// URL encoded parameters
            
            do {
                return try Alamofire.URLEncoding().encode(req as URLRequestConvertible, with: route.parameters)
            } catch {
                // Handle the error thrown when the JSON encoding failed and return a request accordingly
                return req //crude hack to get it compiled!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            }
            
            //return ParameterEncoding.url.encode(req, parameters: route.parameters).0
		default:
			// JSON encoded parameters
			if let params = route.parameters {
				guard JSONSerialization.isValidJSONObject(params) else {
					// Shouldn't get here! If we did, then parameters can't be converted to JSON, and the app would crash,
					// so we don't encode parameters at all, likely leading to a HTTP request failure down the line
					// TODO: better way to handle this?
					NSLog("Invalid parameter(s), cannot be encoded as JSON: %@", params)
					return req
				}
                
                do {
                    return try Alamofire.JSONEncoding().encode(req as URLRequestConvertible, with: params)
                    
                } catch {
                    // Handle the error thrown when the JSON encoding failed and return a request accordingly
                    return req
                }

                
				//return ParameterEncoding.json.encode(req, parameters: params).0
			}
			else {
				return req
			}
		}
	}
}
