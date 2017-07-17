//
//  IdentityTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 7/8/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class IdentityTests: XCTestCase, MockData {
	
	var json: [String: Any]!
	
    override func setUp() {
		super.setUp()
		json = readJSONDictionary(fileName: "MockIdentity")!
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testThatItInits() {
		
		// Given
		
		// When
		guard let identity = try? Identity(json: json) else {
			return XCTFail()
		}
		
		// Then
		XCTAssertNotNil(identity.displayName)
		XCTAssertNotNil(identity.lastModifiedDate)
		XCTAssertNotNil(identity.orgID)
		XCTAssertNotNil(identity.userID)
		XCTAssertNotNil(identity.userType)
		
		XCTAssertEqual(identity.displayName, "Martin Van Nostrand")
		XCTAssertNil(identity.mobilePhone)
		XCTAssertEqual(identity.username, "martin@vandelayindustries.com")
		XCTAssertEqual(identity.userID, "005i00000016PdaBAE")
		XCTAssertEqual(identity.orgID, "00Di0000000bcK3FAI")
		XCTAssertEqual(identity.userType, "STANDARD")
		XCTAssertEqual(identity.language!, "en_US")
		XCTAssertEqual(identity.lastModifiedDate, DateFormatter.salesforceDateTimeFormatter.date(from: "2017-03-13T16:11:13.000+0000"))
		XCTAssertEqual(identity.locale!, "en_US")
		XCTAssertEqual(identity.thumbnailURL!, URL(string: "https://c.na85.content.force.com/profilephoto/005/T"))
	}
	
	func testThatItWontInt() {
		
		// Given
		json["user_id"] = nil
		
		// When
		let identity = try? Identity(json: json)
		
		// Then
		XCTAssertNil(identity)
	}
}
