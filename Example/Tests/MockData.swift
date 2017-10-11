//
//  MockData.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

protocol MockData: class {
}

extension MockData {
	
	func read(fileName: String, ofType: String = "json") -> Data? {
		guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: ofType) else {
			return nil
		}
		let url = URL(fileURLWithPath: path)
		return try? Data(contentsOf: url)
	}
	
	func readJSONDictionary(fileName: String) -> [String: Any]? {
		guard let data = read(fileName: fileName, ofType: "json"), let json = try? JSONSerialization.jsonObject(with: data) else {
			return nil
		}
		return json as? [String: Any]
	}
	
	func readPropertyList(fileName: String) -> NSDictionary? {
		guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) else {
			return nil
		}
		return dict
	}
	
	func readString(from fileName: String, ofType: String = "txt") -> String? {
		guard let data = read(fileName: fileName, ofType: ofType) else {
			return nil
		}
		return String(data: data, encoding: .utf8)
	}
}
