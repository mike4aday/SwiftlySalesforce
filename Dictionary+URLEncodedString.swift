//
//  Array+URLEncodedString.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/30/18.
//

import Foundation

public extension Dictionary where Key == String, Value == String {
	
	public func percentEncodedString() -> String? {
		var comps = URLComponents()
		comps.queryItems = self.map { URLQueryItem(name: $0.key, value: $0.value) }
		return comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
	}
}
