//
//  QueryResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum RESTResource {
	case query(soql: String, batchSize: Int?, version: String)
	case queryNext(path: String)
	case search(sosl: String, version: String)
	case retrieve(type: String, id: String, fields: [String]?, version: String)
	case insert(type: String, data: Data, version: String)
	case update(type: String, id: String, data: Data, version: String)
	case delete(type: String, id: String, version: String)
	case describe(type: String, version: String)
	case describeGlobal(version: String)
	case fetchFile(baseURL: URL?, path: String?, accept: String)
	case apex(method: URLRequest.HTTPMethod, path: String, queryParameters: [String: String]?, body: Data?, contentType: String, headers: [String: String]?)
	case custom(method: URLRequest.HTTPMethod, baseURL: URL?, path: String?, queryParameters: [String: String]?, body: Data?, contentType: String, headers: [String: String]?)
	case identity(version: String)
	case limits(version: String)
	case registerForNotifications(deviceToken: String, version: String)
}

extension RESTResource: Resource {
	
	internal func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .query(soql, batchSize, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/query"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: ["q" : soql],
				body: nil,
				headers: {
					guard let bs = batchSize else  { return nil }
					return ["Sforce-Query-Options": "batchSize=\(bs)"]
				}()
			)
			
		case let .queryNext(path):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent(path),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: nil,
				body: nil,
				headers: nil
			)
			
		case let .search(sosl, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v43.0/search/"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: ["q": sosl],
				body: nil,
				headers: nil
			)
			
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
			
		case let .fetchFile(baseURL, path, accept):
			return try URLRequest(
				method: .get,
				baseURL: (baseURL ?? authorization.instanceURL).appendingPathComponent(path ?? ""),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: nil,
				body: nil,
				headers:  ["Accept": accept]
			)

		case let .apex(method, path, queryParameters, body, contentType, headers):
			return try URLRequest(
				method: method,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/apexrest\(path)"),
				accessToken: authorization.accessToken,
				contentType: contentType,
				queryParameters: queryParameters,
				body: body,
				headers:  headers
			)
			
		case let .custom(method, baseURL, path, queryParameters, body, contentType, headers):
			return try URLRequest(
				method: method,
				baseURL: (baseURL ?? authorization.instanceURL).appendingPathComponent(path ?? ""),
				accessToken: authorization.accessToken,
				contentType: contentType,
				queryParameters: queryParameters,
				body: body,
				headers:  headers
			)
			
		case let .identity(version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.identityURL,
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: ["version" : version],
				body: nil,
				headers: nil
			)
			
		case let .limits(version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/limits"),
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
