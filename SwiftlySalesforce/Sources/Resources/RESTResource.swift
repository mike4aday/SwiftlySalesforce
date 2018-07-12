//
//  RESTResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum RESTResource {
	case identity(version: String)
	case limits(version: String)
	case smallFile(url: URL?, path: String?, accept: String?)
	case apex(method: String, path: String, parameters: [String: String]?, body: Data?, headers: [String: String]?)
}

extension RESTResource: URLRequestConvertible {

	func asURLRequest(with authorization: Authorization) throws -> URLRequest {

		switch self {
			
		case let .identity(version):
			let url = authorization.identityURL
			let queryItems = ["version" : version].map { URLQueryItem(name: $0.key, value: $0.value) }
			return try URLRequest(url: url, authorization: authorization, queryItems: queryItems)
			
		case let .limits(version):
			let path = "/services/data/v\(version)/limits"
			return try URLRequest(path: path, authorization: authorization)
			
		case let .smallFile(url, path, accept):
			var u: URL = url ?? authorization.instanceURL
			if let p = path {
				u.appendPathComponent(p)
			}
			return try URLRequest(url: u, authorization: authorization, accept: accept)
			
		case let .apex(method, path, parameters, body, headers):
			let url = authorization.instanceURL.appendingPathComponent("/services/apexrest").appendingPathComponent(path)
			let queryItems = parameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
			var req = try URLRequest(url: url, authorization: authorization, queryItems: queryItems, method: method, body: body)
			let _ = headers?.map { req.addValue($0.value, forHTTPHeaderField: $0.key) }
			return req
		}
	}
}
