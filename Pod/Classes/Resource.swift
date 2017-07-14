//
//  Resource.swift
//  SwiftlySalesforce
//
//	For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod

public enum Resource {
	case identity(version: String)
	case limits(version: String)
	case query(soql: String, version: String)
	case queryNext(path: String)
	case retrieve(type: String, id: String, fields: [String]?, version: String)
	case insert(type: String, fields: [String: Any], version: String)
	case update(type: String, id: String, fields: [String: Any], version: String)
	case delete(type: String, id: String, version: String)
	case describe(type: String, version: String)
	case describeGlobal(version: String)
	case registerForNotifications(deviceToken: String, version: String)
	case apex(method: HTTPMethod, path: String, parameters: [String: Any]?, headers: [String: String]?)
	case custom(method: HTTPMethod, baseURL: URL?, path: String?, parameters: [String: Any]?, headers: [String: String]?)
}

extension Resource {
	
	var _res: (method: HTTPMethod, path: String?, parameters: [String: Any]?, headers: [String: String]?) {
		
		switch self {
			
		case let .identity(version):
			return (method: .get, path: nil, parameters: ["version": version], headers: nil)
			
		case let .limits(version):
			return (method: .get, path: "/services/data/v\(version)/limits", parameters: nil, headers: nil)
			
		case let .query(soql, version):
			return (method: .get, path: "/services/data/v\(version)/query", parameters: ["q": soql], headers: nil)
			
		case let .queryNext(path):
			return (method: .get, path: path, parameters: nil, headers: nil)
			
		case let .retrieve(type, id, fields, version):
			let params: [String: Any]? = {
				if let fieldNames = fields?.joined(separator: ",") { return ["fields": fieldNames] }
				else { return nil }
			}()
			return (method: .get, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", parameters: params, headers: nil)
			
		case let .insert(type, fields, version):
			return (method: .post, path: "/services/data/v\(version)/sobjects/\(type)/", parameters: fields, headers: ["Content-Type" : "application/json"])
			
		case let .update(type, id, fields, version):
			return (method: .patch, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", parameters: fields, headers: ["Content-Type" : "application/json"])
			
		case let .delete(type, id, version):
			return (method: .delete, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", parameters: nil, headers: nil)
			
		case let .describe(type, version):
			return (method: .get, path: "/services/data/v\(version)/sobjects/\(type)/describe", parameters: nil, headers: nil)
			
		case let .describeGlobal(version):
			return (method: .get, path: "/services/data/v\(version)/sobjects/", parameters: nil, headers: nil)
			
		case let .registerForNotifications(deviceToken, version):
			return (method: .post, path: "/services/data/v\(version)/sobjects/MobilePushServiceDevice", parameters: ["ConnectionToken" : deviceToken, "ServiceType" : "Apple" ], headers: ["Content-Type" : "application/json"])
		
		case let .apex(method, path, parameters, headers):
			return (method: method, path: "/services/apexrest\(path)", parameters: parameters, headers: headers)
			
		case let .custom(method, _, path, parameters, headers):
			return (method: method, path: path, parameters: parameters, headers: headers)
		}
	}

	func asURLRequest(authData: OAuth2Result) throws -> URLRequest {
		
		let defaultHeaders = ["Accept": "application/json", "Authorization": "Bearer \(authData.accessToken)"]
		
		var url: URL = {
			switch self {
			case .identity:
				return authData.identityURL
			case let .custom(_, baseURL, _, _, _):
				return baseURL ?? authData.instanceURL
			default:
				return authData.instanceURL
			}
		}()
		if let p = _res.path {
			url = url.appendingPathComponent(p)
		}
		
		var req = try URLRequest(url: url, method: _res.method, headers: _res.headers)
		for header in defaultHeaders {
			req.addValue(header.value, forHTTPHeaderField: header.key)
		}
		
		let encode = _res.method == .get ? URLEncoding.default.encode : JSONEncoding.default.encode
		return try encode(req, _res.parameters)
	}
}
