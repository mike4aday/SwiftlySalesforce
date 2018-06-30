//
//  SearchResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum SearchResource {
	case search(sosl: String, version: String)
}

extension SearchResource: Resource {
	
	internal func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .search(sosl, version):
			return try URLRequest(
				method: URLRequest.HTTPMethod.get.rawValue,
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/search/"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters:  ["q": sosl],
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
		}
	}
}
