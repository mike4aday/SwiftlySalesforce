//
//  SObjectResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum SObjectResource {
	case retrieve(type: String, id: String, fields: [String]?, version: String)
	case insert(type: String, data: Data, version: String)
	case update(type: String, id: String, data: Data, version: String)
	case delete(type: String, id: String, version: String)
	case describe(type: String, version: String)
	case describeGlobal(version: String)
	case registerForNotifications(deviceToken: String, version: String)
}

extension SObjectResource: URLRequestConvertible {
	
	func asURLRequest(with authorization: Authorization) throws -> URLRequest {
				
		var path: String
		var method: String = "GET"
		var queryItems: [URLQueryItem]? = nil
		var body: Data? = nil
		
		switch self {
		
		case let .retrieve(type, id, fields, version):
			path = "/services/data/v\(version)/sobjects/\(type)/\(id)"
			if let fields = fields {
				queryItems = ["fields": fields.joined(separator: ",")].map { URLQueryItem(name: $0.key, value: $0.value) }
			}
			
		case let .insert(type, data, version):
			path = "/services/data/v\(version)/sobjects/\(type)/"
			method = "POST"
			body = data
			
		case let .update(type, id, data, version):
			path = "/services/data/v\(version)/sobjects/\(type)/\(id)"
			method = "PATCH"
			body = data
			
		case let .delete(type, id, version):
			path = "/services/data/v\(version)/sobjects/\(type)/\(id)"
			method = "DELETE"
			
		case let .describe(type, version):
			path = "/services/data/v\(version)/sobjects/\(type)/describe"
			
		case let .describeGlobal(version):
			path = "/services/data/v\(version)/sobjects/"
			
		case let .registerForNotifications(deviceToken, version):
			path = "/services/data/v\(version)/sobjects/MobilePushServiceDevice"
			method = "POST"
			body = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(["ConnectionToken" : deviceToken, "ServiceType" : "Apple" ])
		}
			
		return try URLRequest(path: path, authorization: authorization, queryItems: queryItems, method: method, body: body)
	}
}
