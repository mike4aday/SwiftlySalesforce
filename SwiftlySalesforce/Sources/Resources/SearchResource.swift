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

extension SearchResource: URLRequestConvertible {
	
	func asURLRequest(with authorization: Authorization) throws -> URLRequest {

		switch self {
			
		case let .search(sosl, version):
			let path = "/services/data/v\(version)/search/"
			let queryItems = ["q": sosl].map { URLQueryItem(name: $0.key, value: $0.value) }
			return try URLRequest(path: path, authorization: authorization, queryItems: queryItems)
		}
	}
}
