//
//  Resource+URLRequest.swift
//  Pods-SwiftlySalesforce_Example
//
//  Created by Michael Epstein on 6/13/18.
//

import Foundation

internal extension Resource {
	
	internal func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .query(soql, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/query"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: ["q" : soql],
				body: nil,
				headers: nil
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
