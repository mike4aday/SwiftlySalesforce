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
	
	internal func request(with authorization: Authorization) -> URLRequest {
		
		switch self {
			
		case let .query(soql, version):
			let url = authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/query")
			let params = ["q" : soql]
			return try URLRequest(url: url, accessToken: authorization.accessToken, queryParameters: params, httpMethod: .get, contentType: contentTypeURLEncoded)
		}
	}
}

fileprivate extension URLRequest {
	
	fileprivate init(
		url: URL,
		accessToken: String,
		queryParameters: [String: Any?]? = nil,
		httpBody: Data? = nil,
		headers: [String: String]? = nil,
		httpMethod: Resource.HTTPMethod,
		contentType: String) throws {
		
		// URL
		if let params = queryParameters {
			guard var _comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
			}
			_comps.queryItems = params.map {
				param in
				if let value = param.value {
					return URLQueryItem(name: param.key, value: "\(value)")
				}
				else {
					return URLQueryItem(name: param.key, value: nil)
				}
			}
			_comps.percentEncodedQuery = _comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
			guard let _url = _comps.url else {
				throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
			}
			self.init(url: _url)
		}
		else {
			self.init(url: url)
		}
		
		// Standard headers
		self.setValue("Bearer \(authData.accessToken)", forHTTPHeaderField: "Authorization")
		self.setValue("application/json", forHTTPHeaderField: "Accept")
		self.httpMethod = httpMethod.rawValue
		self.setValue(contentType, forHTTPHeaderField: "Content-Type")
		
		// Custom headers
		if let headers = headers {
			for header in headers {
				self.setValue(header.value, forHTTPHeaderField: header.key)
			}
		}
		
		// Body data
		self.httpBody = httpBody ?? nil
	}
}
