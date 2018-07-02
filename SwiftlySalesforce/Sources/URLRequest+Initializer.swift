//
//  URLRequest+Initializer.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension URLRequest {
	
	public enum MIMEType: String {
		case json = "application/json"
		case urlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
		case anyImage = "image/*"
	}
	
	public init(
		method: String = "GET",
		url: URL,
		body: Data? = nil,
		accessToken: String,
		additionalQueryParameters: [String: String]? = nil,
		additionalHeaders: [String: String]? = nil,
		contentType: String = MIMEType.urlEncoded.rawValue) throws {
		
		// Components from URL
		guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLErrorKey: url])
		}
		
		// Query items
		if let additionalQueryItems = additionalQueryParameters?.map({ URLQueryItem(name: $0.key, value: $0.value) }) {
			let allQueryItems = additionalQueryItems + (comps.queryItems ?? [])
			comps.queryItems = allQueryItems
		}
		comps.percentEncodedQuery = comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

		// The final URL
		guard let url = comps.url else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSLocalizedDescriptionKey: "Can't create URL from components"])
		}
		self.init(url: url)
		
		// Method
		self.httpMethod = method
		
		// Standard headers
		self.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		self.setValue(contentType, forHTTPHeaderField: "Content-Type")
		
		// Additional headers (these could override standard headers)
		for header in (additionalHeaders ?? [:]) {
			self.setValue(header.value, forHTTPHeaderField: header.key)
		}
		
		// Body data
		self.httpBody = body ?? nil
	}	
}
