//
//  OrganizationTests.swift
//  SwiftlySalesforce_Tests
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class OrganizationTests: XCTestCase, MockData {
	
	let decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateTimeFormatter)
	
	func testThatItInitsFromDecoder() {
		
		let data = read(fileName: "MockOrganization", ofType: "json")!
		let org = try! decoder.decode(Organization.self, from: data)
		
		XCTAssertEqual("Mega Corp., Inc.", org.name)
		XCTAssertNil(org.division)
		XCTAssertEqual("New York", org.address?.city)
		XCTAssertEqual("NY", org.address?.state)
		XCTAssertEqual("10024", org.address?.postalCode)
		XCTAssertEqual("US", org.address?.country)
		XCTAssertEqual("(212) 555-1212", org.phone)
		XCTAssertEqual("Jane Jackson", org.primaryContact)
		XCTAssertEqual("jane.jackson.1234@yahoo.com", org.complianceBCCEmail)
		XCTAssertFalse(org.isSandbox)
		XCTAssertNil(org.trialExpirationDate)
		XCTAssertEqual("Developer Edition", org.type)
		XCTAssertEqual("playgroundorg", org.namespacePrefix)
		XCTAssertEqual("NA88", org.instanceName)
		XCTAssertEqual(1206, org.monthlyPageViewsUsed)
		XCTAssertEqual(100000, org.monthlyPageViewsEntitlement)
	}
}

