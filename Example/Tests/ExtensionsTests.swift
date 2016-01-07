//
//  ExtensionsTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest

class ExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSalesforceDateTimeFormatter() {
		let dateString = "2015-09-21T13:31:23.909+0000"
		if	let date = NSDateFormatter.SalesforceDateTime.dateFromString(dateString),
			let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian),
			let timeZone = NSTimeZone(abbreviation: "GMT") {
				
			let comps = calendar.componentsInTimeZone(timeZone, fromDate: date)
			XCTAssertEqual(comps.year, 2015)
			XCTAssertEqual(comps.month, 9)
			XCTAssertEqual(comps.day, 21)
			XCTAssertEqual(comps.hour, 13)
			XCTAssertEqual(comps.minute, 31)
			XCTAssertEqual(comps.second, 23)
		}
		else {
			XCTFail()
		}
    }
	
	func testSalesforceDateFormatter() {
		let dateString = "2015-09-21"
		if	let date = NSDateFormatter.SalesforceDate.dateFromString(dateString),
			let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
				
				let comps = calendar.componentsInTimeZone(NSTimeZone(), fromDate: date)
				XCTAssertEqual(comps.year, 2015)
				XCTAssertEqual(comps.month, 9)
				XCTAssertEqual(comps.day, 21)
				XCTAssertEqual(comps.hour, 0)
				XCTAssertEqual(comps.minute, 0)
				XCTAssertEqual(comps.second, 0)
		}
		else {
			XCTFail()
		}
	}
	
	func testAddQueryItems() {
		
		let host = "https://www.salesforce.com"
		let params = ["name1": "value1", "name2": "value2", "name3": "value3"]
		
		let comps1 = NSURLComponents(string: host)
		comps1?.addQueryItems(params)
		
		let comps2 = NSURLComponents(string: host)
		comps2?.queryItems = [NSURLQueryItem]()
		for (name,value) in params {
			let queryItem = NSURLQueryItem(name: name, value: value)
			comps2?.queryItems?.append(queryItem)
		}
		
		XCTAssertEqual(comps1, comps2)
	}
}
