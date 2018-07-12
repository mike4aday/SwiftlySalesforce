//
//  AddressTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class AddressTests: XCTestCase {
	
	let json = """
	{
		"city" : "Burlington",
		"country" : "USA",
		"countryCode" : null,
		"geocodeAccuracy" : "Block",
		"latitude" : 36.090709,
		"longitude" : -79.437266,
		"postalCode" : "27215",
		"state" : "NC",
		"stateCode" : null,
		"street" : "525 S. Lexington Ave."
	}
	"""
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatItInitsWithJSON() {
	
		guard let data = json.data(using: .utf8), let address = try? JSONDecoder().decode(Address.self, from: data) else {
			XCTFail()
			return
		}
		
		XCTAssertEqual("Burlington", address.city)
		XCTAssertEqual("USA", address.country)
		XCTAssertNil(address.countryCode)
		XCTAssertEqual(Address.GeocodeAccuracy.block, address.geocodeAccuracy)
		XCTAssertEqual(36.090709, address.latitude)
		XCTAssertEqual(-79.437266, address.longitude)
		XCTAssertEqual("27215", address.postalCode)
		XCTAssertEqual("NC", address.state)
		XCTAssertEqual("525 S. Lexington Ave.", address.street)
	}
}
