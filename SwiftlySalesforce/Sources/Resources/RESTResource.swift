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
	case smallFile(baseURL: URL?, path: String?, accept: String)
	case apex(method: URLRequest.HTTPMethod, path: String, queryParameters: [String: String]?, body: Data?, contentType: String, headers: [String: String]?)
	case custom(method: URLRequest.HTTPMethod, baseURL: URL?, path: String?, queryParameters: [String: String]?, body: Data?, contentType: String, headers: [String: String]?)
}

extension RESTResource: Resource {

	func request(with authorization: Authorization) throws -> URLRequest {

		switch self {
			
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
			
		case let .smallFile(baseURL, path, accept):
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
		}
	}
}
