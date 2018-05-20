//
//  URLComponents+Parameters.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation

public extension URLComponents {
	
	init?(string: String, parameters: [String: Any]?) {
		self.init(string: string)
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
	}
	
	init?(url: URL, parameters: [String: Any]?) {
		self.init(url: url, resolvingAgainstBaseURL: false)
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
	}
}
