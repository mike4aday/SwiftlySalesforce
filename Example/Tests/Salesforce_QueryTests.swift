//
//  Salesforce_RESTTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_QueryTests: XCTestCase {
    
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
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testThatItQueries() {
		//TODO: don't assume existing accounts
		let exp = expectation(description: "Queries 2 accounts")
		salesforce.query(soql: "SELECT Id,Name,CreatedDate FROM Account LIMIT 2").done { (queryResult) in
			XCTAssertEqual(queryResult.totalSize, 2)
			XCTAssertEqual(queryResult.records.count, 2)
			XCTAssertTrue(queryResult.isDone)
			for record in queryResult.records {
				XCTAssertNotNil(record.id)
				XCTAssertNotNil(record.string(forField: "Name"))
				XCTAssertNotNil(record.date(forField: "CreatedDate"))
			}
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItQueriesMultiplePages() {
		//TODO: don't assume enough existing accounts for multiple pages
		let exp = expectation(description: "Queries multiple pages of accounts")
		let batchSize = 201
		salesforce.query(soql: "SELECT Id,Name,CreatedDate FROM Account", batchSize: batchSize).done { (queryResult) in
			XCTAssertTrue(queryResult.totalSize > batchSize)
			XCTAssertTrue(queryResult.records.count == batchSize)
			XCTAssertFalse(queryResult.isDone)
			XCTAssertNotNil(queryResult.nextRecordsPath)
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
}
