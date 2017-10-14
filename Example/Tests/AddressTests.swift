//
//  AddressTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class AddressTests: XCTestCase, MockData {
	
	let decoder = JSONDecoder()
	
	override func setUp() {
		super.setUp()
		decoder.dateDecodingStrategy = .formatted(DateFormatter.salesforceDateFormatter)
	}
	
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItInits() {
		
		let data = read(fileName: "MockAddress", ofType: "json")!
		let address = try! decoder.decode(Address.self, from: data)
		
		XCTAssertEqual(address.city, "Burlington")
		XCTAssertEqual(address.country, "USA")
		XCTAssertNil(address.countryCode)
		XCTAssertEqual(address.geocodeAccuracy, Address.GeocodeAccuracy.block)
		XCTAssertEqual(address.latitude, 36.090709)
		XCTAssertEqual(address.longitude, -79.437266)
		XCTAssertEqual(address.postalCode, "27215")
		XCTAssertEqual(address.state, "NC")
		XCTAssertNil(address.stateCode)
		XCTAssertEqual(address.street, "525 S. Lexington Ave.")
	}
}
