//
//  ExtensionTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ExtensionTests: XCTestCase {
    
	func testThatItParsesSalesforceDateTime() {
		
		let dateString = "2015-09-21T13:31:23.909+0000"
		let date = DateFormatter.salesforceDateTimeFormatter.date(from: dateString)
		let comps = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(abbreviation: "GMT")!, from: date!)

		XCTAssertNotNil(date)
		XCTAssertEqual(comps.year, 2015)
		XCTAssertEqual(comps.month, 9)
		XCTAssertEqual(comps.day, 21)
		XCTAssertEqual(comps.hour, 13)
		XCTAssertEqual(comps.minute, 31)
		XCTAssertEqual(comps.second, 23)
	}
	
	func testThatItParsesSalesforceDate() {
		
		let dateString = "2015-09-21"
		let date = DateFormatter.salesforceDateFormatter.date(from: dateString)
		
		XCTAssertNotNil(date)
		let comps = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(abbreviation: "GMT")!, from: date!)
		XCTAssertEqual(comps.year, 2015)
		XCTAssertEqual(comps.month, 9)
		XCTAssertEqual(comps.day, 21)
	}
	
	func testThatItInitializesURLWithOptionalString() {
		
		let s1: String? = nil
		let s2: String? = "www.salesforce.com"
		let url1 = URL(string: s1)
		let url2 = URL(string: s2)
		
		XCTAssertNil(url1)
		XCTAssertNotNil(url2)
	}
	
	func testThatItGetsQueryItemsFromURL() {
		
		let url = URL(string: "https://www.salesforce.com/test?name1=value1&name2=value2")!
		let url2 = URL(string: "https://www.salesforce.com/test")!

		XCTAssertEqual(url.value(forQueryItem: "name1"), "value1")
		XCTAssertEqual(url.value(forQueryItem: "name2"), "value2")
		XCTAssertNil(url.value(forQueryItem: "SOMETHING"))
		XCTAssertNil(url2.value(forQueryItem: "SOMETHING"))
	}
}
