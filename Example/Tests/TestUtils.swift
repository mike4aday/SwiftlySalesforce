//
//  TestUtils.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

@testable import SwiftlySalesforce

class TestUtils {
	
	static let shared = TestUtils()
	
	private init() {
		// Can't init
	}
	
	func read(fileName: String, ofType: String = "json") -> Data? {
		guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: ofType) else {
			return nil
		}
		let url = URL(fileURLWithPath: path)
		return try? Data(contentsOf: url)
	}
}
