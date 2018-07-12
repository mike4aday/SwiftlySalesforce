//
//  URL+QueryItems.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension URL {
	
	public var queryItems: [URLQueryItem]? {
		guard let comps = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return nil
		}
		return comps.queryItems
	}

	public func queryItems(named: String) -> [URLQueryItem]? {
		return queryItems?.filter { $0.name == named } 
	}
}
