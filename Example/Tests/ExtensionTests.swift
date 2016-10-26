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
		
		// Given
		let dateString = "2015-09-21T13:31:23.909+0000"
		
		// When
		let date = DateFormatter.salesforceDateTimeFormatter.date(from: dateString)
		
		// Then
		XCTAssertNotNil(date)
		let comps = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(abbreviation: "GMT")!, from: date!)
		XCTAssertEqual(comps.year, 2015)
		XCTAssertEqual(comps.month, 9)
		XCTAssertEqual(comps.day, 21)
		XCTAssertEqual(comps.hour, 13)
		XCTAssertEqual(comps.minute, 31)
		XCTAssertEqual(comps.second, 23)
	}
	
	func testThatItParsesSalesforceDate() {
		
		// Given
		let dateString = "2015-09-21"
		
		// When
		let date = DateFormatter.salesforceDateFormatter.date(from: dateString)
		
		// Then
		XCTAssertNotNil(date)
		let comps = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(abbreviation: "GMT")!, from: date!)
		XCTAssertEqual(comps.year, 2015)
		XCTAssertEqual(comps.month, 9)
		XCTAssertEqual(comps.day, 21)
	}
	
	func testThatItInitializesURLWithOptionalString() {
		
		// Given
		let s1: String? = nil
		let s2: String? = "www.salesforce.com"
		
		// When
		let url1 = URL(string: s1)
		let url2 = URL(string: s2)
		
		// Then
		XCTAssertNil(url1)
		XCTAssertNotNil(url2)
	}
}
