//
//  ModelTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ModelTests: XCTestCase, MockJSONData {
	
    override func setUp() {
        super.setUp()
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testThatItInitsUserInfo() {
		
		// Given
		guard let json = identityJSON as? [String: Any] else {
			XCTFail()
			return
		}
		
		// When
		guard let userInfo = try? UserInfo(json: json) else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertEqual(userInfo.displayName!, "Alan Van")
		XCTAssertNil(userInfo.mobilePhone)
		XCTAssertNil(userInfo.username)
		XCTAssertEqual(userInfo.userID!, "005x0000001S2b9")
		XCTAssertEqual(userInfo.orgID!, "00Dx0000001T0zk")
		XCTAssertEqual(userInfo.userType!, "STANDARD")
		XCTAssertEqual(userInfo.language!, "en_US")
		XCTAssertEqual(userInfo.lastModifiedDate!, DateFormatter.salesforceDateTimeFormatter.date(from: "2010-06-28T20:54:09.000+0000"))
		XCTAssertEqual(userInfo.locale!, "en_US")
		XCTAssertEqual(userInfo.thumbnailURL!, URL(string: "https://yourInstance.salesforce.com/profilephoto/005/T"))
	}
	
	func testThatItInitsQueryResult() {
		
		// Given
		guard let json = queryResultJSON as? [String: Any] else {
			XCTFail()
			return
		}
		
		// When
		guard let queryResult = try? QueryResult(json: json) else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertEqual(queryResult.totalSize, 2)
		XCTAssertTrue(queryResult.isDone)
		XCTAssertEqual(queryResult.totalSize, 2)
		XCTAssertEqual(queryResult.records.count, queryResult.totalSize)
	}
}
