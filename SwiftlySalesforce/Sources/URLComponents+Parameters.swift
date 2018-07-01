//
//  URLComponents+Parameters.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//
/*
import Foundation

extension URLComponents {
	
	init?(string: String, parameters: [String: String]? = nil, fragment: String? = nil) {
		guard let url = URL(string: string) else {
			return nil
		}
		self.init(url: url, parameters: parameters, fragment: fragment)
	}
	
	init?(url: URL, parameters: [String: String]? = nil, fragment: String? = nil) {
		self.init(url: url, resolvingAgainstBaseURL: false)
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
		self.fragment = fragment
		self.percentEncodedQuery = self.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
	}
}
*/
