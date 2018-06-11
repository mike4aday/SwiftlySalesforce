//
//  Resource.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation

enum Resource {
	
	case query(soql: String, version: String)
}

extension Resource {
	
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
		}
	}
}
