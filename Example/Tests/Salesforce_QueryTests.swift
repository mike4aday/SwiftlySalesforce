//
//  Salesforce_QueryTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_QueryTests: XCTestCase {
	
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		salesforce = Salesforce(configuration: config)
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
		let exp = expectation(description: "Queries multiple pages of accounts")
		let batchSize = 201
		salesforce.query(soql: "SELECT Id,Name,CreatedDate FROM Account", batchSize: batchSize).done { (queryResult) in
			if queryResult.totalSize > batchSize {
				// Multiple pages of results
				XCTAssertTrue(queryResult.records.count == batchSize)
				XCTAssertFalse(queryResult.isDone)
				XCTAssertNotNil(queryResult.nextRecordsPath)
			}
			else {
				// Single page of results, or none
				XCTAssertTrue(queryResult.records.count <= batchSize)
				XCTAssertTrue(queryResult.isDone)
				XCTAssertNil(queryResult.nextRecordsPath)
			}
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItQueriesWithCustomDecodable() {
		
		struct MyAccount: Decodable {
			var Id: String
			var Name: String
			var BillingCountry: String?
			var BillingCity: String?
		}
		
		//TODO: don't assume existing accounts
		let exp = expectation(description: "Queries into custom decodable")
		salesforce.query(soql: "SELECT Id,Name,CreatedDate,BillingCountry,BillingCity FROM Account").done { (queryResult: QueryResult<MyAccount>) in
			for record in queryResult.records {
				XCTAssertNotNil(record.Id)
				XCTAssertNotNil(record.Name)
			}
		}.catch { (error) in
			XCTFail("\(error)")
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItPerformsMultipleQueries() {
		//TODO: don't assume existing records or access to Leads
		let exp = expectation(description: "Multiple parallel queries")
		let q1 = "SELECT Id,NAME FROM Account"
		let q2 = "SELECT Id,NAME FROM Contact"
		let q3 = "SELECT Id,Name FROM Lead"
		salesforce.query(soql: [q1,q2,q3]).done { queryResults in
			XCTAssertEqual(queryResults.count, 3)
			XCTAssertEqual("Account", queryResults[0].records[0].type)
			XCTAssertEqual("Contact", queryResults[1].records[0].type)
			XCTAssertEqual("Lead", queryResults[2].records[0].type)
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
}
