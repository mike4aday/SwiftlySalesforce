//
//  AddressTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 7/10/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class AddressTests: XCTestCase, MockData {
	
	var json: [String: Any]!
	
	override func setUp() {
		super.setUp()
		json = readJSONDictionary(fileName: "MockAddress")!
	}
	
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItInits() {
		
		// Given
		
		// When
		let address = Address(json: json)
		
		// Then
		XCTAssertEqual(address.city, "Paris")
		XCTAssertEqual(address.country, "France")
		XCTAssertEqual(address.countryCode, "FR")
		XCTAssertEqual(address.geocodeAccuracy, Address.GeocodeAccuracy.street)
		XCTAssertEqual(address.latitude, 47.84627258324638)
		XCTAssertEqual(address.longitude, 3.3549643597681116)
		XCTAssertEqual(address.postalCode, "75251")
		XCTAssertNil(address.state)
		XCTAssertNil(address.stateCode)
		XCTAssertEqual(address.street, "21 Place Jussieu")
	}
}
