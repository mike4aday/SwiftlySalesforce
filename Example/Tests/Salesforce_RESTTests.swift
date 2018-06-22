//
//  Salesforce+QueryTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 6/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_RESTTests: XCTestCase {
    
	struct ConfigFile: Decodable {
		let consumerKey: String
		let redirectURL: String
	}
	
	var config: Salesforce.Configuration!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let configFile = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(ConfigFile.self, from: data)
		let url = URL(string: configFile.redirectURL)!
		config = try! Salesforce.Configuration(consumerKey: configFile.consumerKey, callbackURL: url)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testThatItQueries() {
		//TODO: don't assume existing accounts
		let exp = expectation(description: "Queries 2 accounts")
		let salesforce = Salesforce(configuration: config)
		salesforce.query(soql: "SELECT Id,Name,CreatedDate FROM Account LIMIT 2").done { (queryResult) in
			XCTAssertEqual(queryResult.totalSize, 2)
			XCTAssertEqual(queryResult.records.count, 2)
			XCTAssertTrue(queryResult.isDone)
			for record in queryResult.records {
				XCTAssertNotNil(record.id)
				XCTAssertNotNil(record.string(forField: "Name"))
				XCTAssertNotNil(record.date(forField: "CreatedDate"))
			}
			exp.fulfill()
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItQueriesMultiplePages() {
		//TODO: don't assume enough existing accounts for multiple pages
		let exp = expectation(description: "Queries multiple pages of accounts")
		let batchSize = 201
		let salesforce = Salesforce(configuration: config)
		salesforce.query(soql: "SELECT Id,Name,CreatedDate FROM Account", batchSize: batchSize).done { (queryResult) in
			XCTAssertTrue(queryResult.totalSize > batchSize)
			XCTAssertTrue(queryResult.records.count == batchSize)
			XCTAssertFalse(queryResult.isDone)
			XCTAssertNotNil(queryResult.nextRecordsPath)
			exp.fulfill()
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItSearches() {
		//TODO: don't assume existing records
		let exp = expectation(description: "Searches with SOSL")
		let salesforce = Salesforce(configuration: config)
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
			exp.fulfill()
		}.catch { error in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
}
