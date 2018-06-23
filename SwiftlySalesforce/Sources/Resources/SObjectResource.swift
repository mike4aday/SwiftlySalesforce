//
//  QueryResource.swift
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

extension SObjectResource: Resource {
	
	internal func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .retrieve(type, id, fields, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: {
					guard let fieldNames = fields?.joined(separator: ",") else { return nil }
					return ["fields": fieldNames]
				}(),
				body: nil,
				headers: nil
			)
			
		case let .insert(type, data, version):
			return try URLRequest(
				method: .post,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.json.rawValue,
				queryParameters: nil,
				body: data,
				headers: nil
			)
			
		case let .update(type, id, data, version):
			return try URLRequest(
				method: .patch,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.json.rawValue,
				queryParameters: nil,
				body: data,
				headers: nil
			)
			
		case let .delete(type, id, version):
			return try URLRequest(
				method: .delete,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: nil,
				body: nil,
				headers: nil
			)

		case let .describe(type, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/describe"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: nil,
				body: nil,
				headers: nil
			)
			
		case let .describeGlobal(version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: nil,
				body: nil,
				headers: nil
			)
			
		case let .registerForNotifications(deviceToken, version):
			return try URLRequest(
				method: .post,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/MobilePushServiceDevice"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.json.rawValue,
				queryParameters: nil,
				body: {
					let encoder = JSONEncoder()
					encoder.dateEncodingStrategy = .formatted(DateFormatter.salesforceDateTimeFormatter)
					return try encoder.encode(["ConnectionToken" : deviceToken, "ServiceType" : "Apple" ])
				}(),
				headers:  nil
			)
		}
	}
}
