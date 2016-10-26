//
//  MockJSONData.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

protocol MockJSONData: class {
	var identityJSON: Any? { get }
	var queryResultJSON: Any? { get }
}

extension MockJSONData {
	
	func read(fileName: String, ofType: String = "json") -> Any? {
		
		guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: ofType) else {
			return nil
		}
		let url = URL(fileURLWithPath: path)
		guard let data = try? Data(contentsOf: url),
			let json = try? JSONSerialization.jsonObject(with: data) else {
			return nil
		}
		return json
	}
	
	var identityJSON: Any? {
		return read(fileName: "IdentityResponse", ofType: "json")
	}
	
	var queryResultJSON: Any? {
		return read(fileName: "QueryResponse", ofType: "json")
	}
}
