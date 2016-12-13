//
//  MockJSONData.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

protocol MockJSONData: class {
	var identityJSON: [String: Any]? { get }
	var queryResultJSON: [String: Any]? { get }
	var describeAccountResultJSON: [String: Any]? { get }
	var describeTaskResultJSON: [String: Any]? { get }
}

extension MockJSONData {
	
	func read<T>(fileName: String, ofType: String = "json") -> T? {
		guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: ofType) else {
			return nil
		}
		let url = URL(fileURLWithPath: path)
		guard let data = try? Data(contentsOf: url), let json = try? JSONSerialization.jsonObject(with: data) else {
			return nil
		}
		return json as? T
	}
	
	var identityJSON: [String: Any]? {
		return read(fileName: "IdentityResult", ofType: "json")
	}
	
	var queryResultJSON: [String: Any]? {
		return read(fileName: "QueryResult", ofType: "json")
	}
	
	var describeAccountResultJSON: [String: Any]? {
		return read(fileName: "DescribeAccountResult", ofType: "json")
	}
	
	var describeTaskResultJSON: [String: Any]? {
		return read(fileName: "DescribeTaskResult", ofType: "json")
	}
}
