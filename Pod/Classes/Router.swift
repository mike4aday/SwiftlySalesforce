//
//  Router.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod

public enum Router {
	case identity(authData: AuthData, version: String)
	case limits(authData: AuthData, version: String)
	case query(soql: String, authData: AuthData, version: String)
	case queryNext(path: String, authData: AuthData)
	case retrieve(type: String, id: String, fields: [String]?, authData: AuthData, version: String)
	case insert(type: String, fields: [String: Any], authData: AuthData, version: String)
	case update(type: String, id: String, fields: [String: Any], authData: AuthData, version: String)
	case delete(type: String, id: String, authData: AuthData, version: String)
	case describe(type: String, authData: AuthData, version: String)
	case apexREST(method: HTTPMethod, path: String, parameters: [String: Any]?, headers: [String: String]?, authData: AuthData)
	case custom(method: HTTPMethod, path: String, parameters: [String: Any]?, headers: [String: String]?, authData: AuthData)
}

extension Router: URLRequestConvertible {
	
	public func asURLRequest() throws -> URLRequest {
		
		switch self {
		
		case let .identity(authData, version):
			return try build(authData: authData, baseURL: authData.identityURL, params: ["version": version])
			
		case let .limits(authData, version):
			return try build(authData: authData, path: "/services/data/v\(version)/limits")
		
		case let .query(soql, authData, version):
			return try build(authData: authData, path: "/services/data/v\(version)/query", params: ["q": soql])
		
		case let .queryNext(path, authData):
			return try build(authData: authData, path: path)
			
		case let .retrieve(type, id, fields, authData, version):
			var params: [String: String]? = nil
			if let fieldNames = fields?.joined(separator: ",") {
				params = ["fields": fieldNames]
			}
			return try build(authData: authData, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", params: params)
			
		case let .insert(type, fields, authData, version):
			return try build(authData: authData, method: .post, path: "/services/data/v\(version)/sobjects/\(type)/", params: fields)
			
		case let .update(type, id, fields, authData, version):
			return try build(authData: authData, method: .patch, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", params: fields)
			
		case let .delete(type, id, authData, version):
			return try build(authData: authData, method: .delete, path: "/services/data/v\(version)/sobjects/\(type)/\(id)")
			
		case let .describe(type, authData, version):
			return try build(authData: authData, path: "/services/data/v\(version)/sobjects/\(type)/describe")
			
		case let .apexREST(method, path, parameters, headers, authData):
			return try build(authData: authData, method: method, path: "/services/apexrest\(path)", params: parameters, headers: headers)
			
		case let .custom(method, path, parameters, headers, authData):
			return try build(authData: authData, method: method, path: path, params: parameters, headers: headers)
		}
	}
	
	fileprivate func build(authData: AuthData, method: HTTPMethod = .get, baseURL: URL? = nil, path: String? = nil, params: [String: Any]? = nil, headers: [String: String]? = nil) throws -> URLRequest {
		
		let defaultHeaders = ["Accept": "application/json", "Authorization": "Bearer \(authData.accessToken)"]
		
		var url = (baseURL ?? authData.instanceURL)
		if let p = path {
			url = url.appendingPathComponent(p)
		}
		var req = try URLRequest(url: url, method: method, headers: headers)
		for header in defaultHeaders {
			req.setValue(header.value, forHTTPHeaderField: header.key)
		}
		
		let encode = method == .get ? URLEncoding.default.encode : JSONEncoding.default.encode
		return try encode(req, params)
	}
}


