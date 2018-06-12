//
//  URLComponents+Parameters.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/20/18.
//

import Foundation

extension URLComponents {
	
	init?(string: String, parameters: [String: String]?) {
		guard let url = URL(string: string) else {
			return nil
		}
		self.init(url: url, parameters: parameters)
	}
	
	init?(url: URL, parameters: [String: String]?) {
		self.init(url: url, resolvingAgainstBaseURL: false)
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
		self.percentEncodedQuery = self.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
	}
}
