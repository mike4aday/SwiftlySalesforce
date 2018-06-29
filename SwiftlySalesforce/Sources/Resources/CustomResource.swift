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
	var baseURL: URL?
	var path: String?
	var queryParameters: [String: String]?
	var body: Data?
	var contentType: String
	var headers: [String: String]?
}

extension CustomResource: Resource {
	
	func request(with authorization: Authorization) throws -> URLRequest {
		return try URLRequest(
			method: {
				guard let httpMethod = URLRequest.HTTPMethod(rawValue: method) else {
					throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSLocalizedDescriptionKey: "Unsupported method: \(method)"])
				}
				return httpMethod
			}(),
			baseURL: (baseURL ?? authorization.instanceURL).appendingPathComponent(path ?? ""),
			accessToken: authorization.accessToken,
			contentType: contentType,
			queryParameters: queryParameters,
			body: body,
			headers:  headers
		)
	}
}
