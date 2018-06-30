//
//  CustomResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//


import Foundation

internal struct CustomResource {
	var method: String
	var url: URL?
	var path: String?
	var queryParameters: [String: String]?
	var body: Data?
	var contentType: String
	var headers: [String: String]?
}

extension CustomResource: Resource {
	
	func request(with authorization: Authorization) throws -> URLRequest {
		return try URLRequest(
			method: method,
			url: {
				var u = url ?? authorization.instanceURL
				if let path = path {
					u.appendPathComponent(path)
				}
				return u
			}(),
			body: body, accessToken: authorization.accessToken,
			additionalQueryParameters: queryParameters,
			additionalHeaders:  headers, contentType: contentType
		)
	}
}
