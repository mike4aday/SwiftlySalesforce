//
//  URLRequest+Initializer.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation

public extension URLRequest {
	
	public enum HTTPMethod: String {
		case options = "OPTIONS"
		case get     = "GET"
		case head    = "HEAD"
		case post    = "POST"
		case put     = "PUT"
		case patch   = "PATCH"
		case delete  = "DELETE"
		case trace   = "TRACE"
		case connect = "CONNECT"
	}
	
	public enum ContentType: String {
		case json = "application/json"
		case urlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
	}
	
	public init(
		method: HTTPMethod,
		baseURL: URL,
		accessToken: String,
		contentType: ContentType,
		queryParameters: [String: String]? = nil,
		body: Data? = nil,
		headers: [String: String]? = nil) throws {
		
		// URL
		guard let comps = URLComponents(url: baseURL, parameters: queryParameters), let url = comps.url else {
			//TODO: more information in userInfo dictionary
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLErrorKey: baseURL])
		}
		self.init(url: url)
		
		// Method
		self.httpMethod = method.rawValue
		
		// Standard headers
		self.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		self.setValue("application/json", forHTTPHeaderField: "Accept")
		self.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
		
		// Custom headers
		if let headers = headers {
			for header in headers {
				self.setValue(header.value, forHTTPHeaderField: header.key)
			}
		}
		
		// Body data
		self.httpBody = body ?? nil
	}
}
