//
//  URLRequest+Initializer.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal extension URLRequest {
	
	internal enum MIMEType: String {
		case json = "application/json"
		case urlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
	}

	internal init(path: String,
				  authorization: Authorization,
				  queryItems: [URLQueryItem]? = nil,
				  method: String? = nil,
				  body: Data? = nil,
				  contentType: String? = nil,
				  accept: String? = nil) throws {
		
		let url = authorization.instanceURL.appendingPathComponent(path)
		try self.init(url: url, authorization: authorization, queryItems: queryItems, method: method, body: body)
	}
	
	internal init(url: URL,
				  authorization: Authorization,
				  queryItems: [URLQueryItem]? = nil,
				  method: String? = nil,
				  body: Data? = nil,
				  contentType: String? = nil,
				  accept: String? = nil) throws {
		
		// Set default values, if not specified
		var method = method ?? "GET"
		var contentType = contentType ??
			method.uppercased() == "GET" || method.uppercased() == "DELETE"
			? MIMEType.urlEncoded.rawValue
			: MIMEType.json.rawValue
		var accept = accept ?? MIMEType.json.rawValue
		
		// Add additional query items, if any
		var myURL = url
		if let additionalQueryItems = queryItems {
			guard var comps = URLComponents(url: myURL, resolvingAgainstBaseURL: false) else {
				throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLErrorKey: myURL.absoluteString])
			}
			comps.queryItems = additionalQueryItems + (comps.queryItems ?? [])
			guard let updatedURL = comps.url else {
				throw Salesforce.Error.badRequest(message: nil)
			}
			myURL = updatedURL
		}
		
		self.init(url: myURL)
		self.httpMethod = method
		self.httpBody = body
		self.setValue(contentType, forHTTPHeaderField: "Content-Type")
		self.setValue(accept, forHTTPHeaderField: "Accept")
		try apply(authorization)
	}
	
	internal mutating func apply(_ authorization: Authorization) throws {
		
		guard let url = self.url, var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw Salesforce.Error.badRequest(message: "Unable to apply authorization values to URL request.")
		}
		
		// Set access token header
		setValue("Bearer \(authorization.accessToken)", forHTTPHeaderField: "Authorization")
		
		// Hostname & scheme set?
		if comps.host == nil {
			comps.host = authorization.instanceURL.host
		}
		if comps.scheme == nil {
			comps.scheme = authorization.instanceURL.scheme
		}
		
		// In case any query string value contains "+"...
		comps.percentEncodedQuery = comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B") // As Salesforce expects
		
		self.url = comps.url
	}
}
