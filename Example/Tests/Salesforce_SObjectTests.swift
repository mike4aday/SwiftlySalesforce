//
//  Salesforce_SObjectTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 7/2/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_SObjectTests: XCTestCase {
	
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let testConfig = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		salesforce = Salesforce(configuration: testConfig)
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testThatItInsertsRetrievesAndDeletes() {
		let exp = expectation(description: "Inserts, retrieves and deletes 1 account")
		firstly {
			salesforce.insert(type: "Account", fields: ["Name":"Really Large Corp., Inc.", "ShippingCountry": "Canada"])
		}
		.then {
			self.salesforce.retrieve(type: "Account", id: $0)
		}.then { (record) -> Promise<Void> in
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.string(forField: "ShippingCountry"), "Canada")
			return self.salesforce.delete(type: "Account", id: record.id!)
		}.catch { error in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 600, handler: nil)
	}
}
