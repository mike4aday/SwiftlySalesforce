//
//  IdentityTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class IdentityTests: XCTestCase {
	
	var decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateTimeFormatter)

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testThatItInitsWithPreWinter19Data() {
		
		let data = TestUtils.shared.read(fileName: "MockIdentityPreWinter19", ofType: "json")!
		let identity = try! decoder.decode(Identity.self, from: data)
		
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
	
	// Date format for 'lastModifiedDate' changed in Winter '19
	// See: https://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/rn_security_auth_json_value_endpoints.htm
	func testThatItInitsWithPostWinter19Data() {
		
		let data = TestUtils.shared.read(fileName: "MockIdentityPostWinter19", ofType: "json")!
		let identity = try! decoder.decode(Identity.self, from: data)
		
		XCTAssertEqual(identity.displayName, "Martin Van Nostrand")
		XCTAssertNil(identity.mobilePhone)
		XCTAssertEqual(identity.username, "martin@vandelayindustries.com")
		XCTAssertEqual(identity.userID, "005B00000088yOcIAI")
		XCTAssertEqual(identity.orgID, "00DB0000008w8cfMAA")
		XCTAssertEqual(identity.userType, "STANDARD")
		XCTAssertEqual(identity.language!, "en_US")
		XCTAssertEqual(identity.lastModifiedDate, DateFormatter.salesforceDateTimeFormatter.date(from: "2018-10-09T13:47:02.000+0000"))
		XCTAssertEqual(identity.locale!, "en_US")
		XCTAssertEqual(identity.thumbnailURL!, URL(string: "https://c.na85.content.force.com/profilephoto/005/T"))
	}
}
