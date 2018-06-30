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
				method: URLRequest.HTTPMethod.get.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: {
					guard let fieldNames = fields?.joined(separator: ",") else { return nil }
					return ["fields": fieldNames]
				}(),
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .insert(type, data, version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.post.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/"),
				body: data,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.json.rawValue
			)
			
		case let .update(type, id, data, version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.patch.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				body: data,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.json.rawValue
			)
			
		case let .delete(type, id, version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.delete.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)

		case let .describe(type, version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.get.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/describe"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .describeGlobal(version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.get.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .registerForNotifications(deviceToken, version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.post.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/MobilePushServiceDevice"),
				body: {
					let encoder = JSONEncoder()
					encoder.dateEncodingStrategy = .formatted(DateFormatter.salesforceDateTimeFormatter)
					return try encoder.encode(["ConnectionToken" : deviceToken, "ServiceType" : "Apple" ])
				}(),
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders:  nil,
				contentType: URLRequest.MIMEType.json.rawValue
			)
		}
	}
}
