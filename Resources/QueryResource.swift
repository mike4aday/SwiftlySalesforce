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

extension QueryResource: Resource {
	
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
		}
	}
}
