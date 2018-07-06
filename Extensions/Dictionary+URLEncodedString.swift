//
//  Dictionary+URLEncodedString.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension Dictionary where Key == String, Value == String {
	
	public func asPercentEncodedString() -> String? {
		var comps = URLComponents()
		comps.queryItems = self.map { URLQueryItem(name: $0.key, value: $0.value) }
		return comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
	}
}
