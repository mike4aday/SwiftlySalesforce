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
				method: "GET",
				url: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/query"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: ["q" : soql],
				additionalHeaders: {
					guard let bs = batchSize else  { return nil }
					return ["Sforce-Query-Options": "batchSize=\(bs)"]
				}(),
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .queryNext(path):
			return try URLRequest(
				method: "GET",
				url: authorization.instanceURL.appendingPathComponent(path),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: nil,
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
		}
	}
}
