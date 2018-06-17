//
//  RESTEndpoint.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation

enum QueryResource {
	case query(soql: String, batchSize: Int?, version: String)
	case queryNext(path: String)
	case retrieve(type: String, id: String, fields: [String]?, version: String)
}

extension QueryResource: Resource {
	
	internal func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .query(soql, batchSize, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/query"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: ["q" : soql],
				body: nil,
				headers: {
					guard let bs = batchSize else  {
						return nil
					}
					return ["Sforce-Query-Options": "batchSize=\(bs)"]
				}()
			)
			
		case let .queryNext(path):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent(path),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: nil,
				body: nil,
				headers: nil
			)
			
		case let .retrieve(type, id, fields, version):
			var params: [String: String]? = nil
			if let fieldNames = fields?.joined(separator: ",")  {
				params = ["fields": fieldNames]
			}
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/sobjects/\(type)/\(id)"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: params,
				body: nil,
				headers: nil
			)
		}
	}
}
