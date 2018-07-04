//
//  Salesforce_SearchTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 7/2/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class Salesforce_SearchTests: XCTestCase {
    
	struct TestConfig: Decodable {
		let consumerKey: String
		let redirectURL: String
	}
	
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let testConfig = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(TestConfig.self, from: data)
		let url = URL(string: testConfig.redirectURL)!
		salesforce = try! Salesforce(consumerKey: testConfig.consumerKey, callbackURL: url)
	}
    
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItSearches() {
		//TODO: don't assume existing records
		let exp = expectation(description: "Searches with SOSL")
		let sosl = """
			FIND {"A*" OR "B*" OR "C*"} IN Name Fields RETURNING lead(name,phone,Id), contact(name,phone)
		"""
		salesforce.search(sosl: sosl).done { result in
			XCTAssertTrue(result.searchRecords.count > 0)
			debugPrint("Search result count: \(result.searchRecords.count)")
			for record in result.searchRecords {
				XCTAssertTrue(record.type.lowercased() == "lead" || record.type.lowercased() == "contact")
				XCTAssertNotNil(record.id)
				XCTAssertNotNil(record.string(forField: "Name"))
				debugPrint("Name: \(record.string(forField: "Name")!)")
			}
		}.catch { error in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
}
