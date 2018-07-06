//
//  URL_QueryItemTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 7/6/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest

class URL_QueryItemTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testThatItGetsQueryItemsFromURL() {
		
		let url = URL(string: "https://www.salesforce.com/test?name1=value1&name2=value2")!
		
		XCTAssertEqual(url.queryItems(named: "name1")!.first!.value, "value1")
		XCTAssertEqual(url.queryItems(named: "name2")!.first!.value, "value2")
	}
}
