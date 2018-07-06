//
//  Salesforce_SearchTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class Salesforce_SearchTests: XCTestCase {
    
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		salesforce = Salesforce(configuration: config)
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
			}
		}.catch { error in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
}
