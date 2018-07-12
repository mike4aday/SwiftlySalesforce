//
//  DateFormatter+SalesforceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest

class DateFormatter_SalesforceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
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
}
