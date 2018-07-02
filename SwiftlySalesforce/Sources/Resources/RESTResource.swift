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
	case smallFile(url: URL?, path: String?)
	case apex(method: String, path: String, queryParameters: [String: String]?, body: Data?, contentType: String, headers: [String: String]?)
}

extension RESTResource: Resource {

	func request(with authorization: Authorization) throws -> URLRequest {

		switch self {
			
		case let .identity(version):
			return try URLRequest(
				method: "GET",
				url: authorization.identityURL,
				body: nil, accessToken: authorization.accessToken,
				additionalQueryParameters: ["version" : version], additionalHeaders: nil, contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .limits(version):
			return try URLRequest(
				method: "GET",
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/limits"),
				body: nil, accessToken: authorization.accessToken,
				additionalQueryParameters: nil, additionalHeaders: nil, contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .smallFile(url, path):
			return try URLRequest(
				method: "GET",
				url: {
					var u = url ?? authorization.instanceURL
					if let path = path {
						u.appendPathComponent(path)
					}
					return u
				}(),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders:  nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .apex(method, path, queryParameters, body, contentType, headers):
			return try URLRequest(
				method: method,
				url: authorization.instanceURL.appendingPathComponent("/services/apexrest\(path)"),
				body: body,
				accessToken: authorization.accessToken,
				additionalQueryParameters: queryParameters,
				additionalHeaders: headers,
				contentType: contentType
			)
		}
	}
}
