//
//  QueryResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum QueryResource {
	case query(soql: String, batchSize: Int?, version: String)
	case queryNext(path: String)
}

extension QueryResource: URLRequestConvertible {
	
	internal func asURLRequest(with authorization: Authorization) throws -> URLRequest {

		switch self {
			
		case let .query(soql, batchSize, version):
			let path = "/services/data/v\(version)/query"
			let queryItems = ["q" : soql].map { URLQueryItem(name: $0.key, value: $0.value)	}
			var req = try URLRequest(path: path, authorization: authorization, queryItems: queryItems)
			if let batchSize = batchSize {
				req.setValue("batchSize=\(batchSize)", forHTTPHeaderField: "Sforce-Query-Options")
			}
			return req
			
		case let .queryNext(path):
			return try URLRequest(path: path, authorization: authorization)
		}
	}
}
