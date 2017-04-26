//
//  SalesforceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
import PromiseKit
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase, MockOAuth2Data, LoginDelegate {
	
	var window: UIWindow?
	
	override func setUp() {
		
		super.setUp()
		
		guard let accessToken = accessToken, let refreshToken = refreshToken, let instanceURL = instanceURL, let identityURL = identityURL, let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		salesforce.authManager.authData = AuthData(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		salesforce.authManager.configuration = AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self)
	}
	
	func testThatItGetsIdentity() {
		
		// Given
		
		// When
		let exp = expectation(description: "Identity")
		salesforce.identity()
			.then {
				// Then
				userInfo -> () in
				debugPrint(userInfo)
				XCTAssertEqual(userInfo.userID!, salesforce.authManager.authData?.userID!)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItGetsLimits() {
		
		// Given
		
		// When
		let exp = expectation(description: "Limits")
		salesforce.limits()
			.then {
				// Then
				limits -> () in
				debugPrint(limits)
				XCTAssertTrue(limits.count > 20) // ~23 as of Winter '17
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 7.0, handler: nil)
	}
	
	func testThatItQueries() {
		
		// Given
		let soql = "SELECT Id FROM Account WHERE CreatedDate > NEXT_WEEK"
		
		// When
		let exp = expectation(description: "Query")
		salesforce.query(soql: soql)
			.then {
				// Then
				queryResult -> () in
				debugPrint(queryResult)
				XCTAssertEqual(queryResult.records.count, 0)
				XCTAssertEqual(queryResult.totalSize, 0)
				XCTAssertTrue(queryResult.isDone)
				XCTAssertNil(queryResult.nextRecordsPath)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItRunsMultipleQueries() {
		
		// Given
		let soqls = ["SELECT Id FROM Account WHERE CreatedDate > NEXT_YEAR", "SELECT Id FROM Contact", "SELECT Id FROM Lead"]
		
		// When
		let exp = expectation(description: "Query")
		salesforce.query(soql: soqls)
			.then {
				// Then
				result -> () in
				debugPrint(result)
				XCTAssertEqual(result.count, 3)
				XCTAssertTrue(result[0].isDone)
				XCTAssertEqual(result[0].totalSize, 0)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItRetrieves() {
		
		// Given
		let type = "Account"
		let soql = "SELECT Id FROM \(type) ORDER BY Id LIMIT 1"
		
		// When
		let exp = expectation(description: "Retrieve \(type) record")
		salesforce.query(soql: soql)
			.then {
				(queryResult) -> Promise<[String: Any]> in
				guard queryResult.records.count == 1, let id = queryResult.records[0]["Id"] as? String else {
					throw SalesforceError.invalidity(message: "No records")
				}
				return salesforce.retrieve(type: type, id: id)
			}.then {
				record -> () in
				guard let attributes = record["attributes"] as? [String: Any], let recordType = attributes["type"] as? String else {
					throw SalesforceError.invalidity(message: "No records")
				}
				XCTAssertEqual(type, recordType)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
			}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItRetrievesMultipleRecords() {
		
		// Given
		let type = "Account"
		let recordsToInsert = [
			["Name": "Account 1"],
			["Name": "Account 2"],
			["Name": "Account 3"],
			["Name": "Account 4"]
		]
		
		// When
		let exp = expectation(description: "Retrieve multiple records")
		let promises = recordsToInsert.map { salesforce.insert(type: type, fields: $0) }
		when(fulfilled: promises).then {
			results in
			return salesforce.retrieve(type: type, ids: results, fields: ["Id,Name,ShippingStreet"])
		}.then {
			// Then
			result -> () in
			debugPrint(result)
			XCTAssertEqual(result.count, recordsToInsert.count)
			exp.fulfill()
		}.catch {
			error in
			XCTFail("\(error)")
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItFailsToRetrieve() {
		
		// Given
		let type = "Account"
		let id = "001xxxxxxxxxxxxxxx"
		
		// When
		let exp = expectation(description: "Retrieve nonexistent \(type) record")
		
		first {
			salesforce.retrieve(type: type, id: id)
		}.then {
			result -> () in
			XCTFail()
		}.catch {
			error in
			debugPrint(error)
			exp.fulfill()
		}
	
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItInserts() {
		
		// Given
		let type = "Account"
		let fields = [ "Name" : "Megacorp, Inc.", "BillingPostalCode": "12345"]
		
		// When
		let exp = expectation(description: "Insert \(type) record")
		first {
			salesforce.insert(type: type, fields: fields)
		}.then {
			// Then
			result -> () in
			debugPrint(result)
			XCTAssertTrue(result.hasPrefix("001"))
			exp.fulfill()
		}.catch {
			error in
			XCTFail("\(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItDescribes() {
		
		// Given
		let type = "Account"
		
		// When
		let exp = expectation(description: "Describe Account")
		salesforce.describe(type: type)
			.then {
				// Then
				desc -> () in
				//debugPrint(desc)
				XCTAssertEqual(desc.name, "Account")
				XCTAssertTrue(desc.fields.count > 0)
				XCTAssertNotNil(desc.fields["Type"])
				XCTAssertEqual(desc.fields["Type"]?.type, "picklist")
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItDescribesAll() {
		
		// Given
		
		// When
		let exp = expectation(description: "Describe All (Describe Global)")
		salesforce.describeAll()
		.then {
			(results: [String: ObjectDescription]) -> () in
			guard let acct = results["Account"], acct.name == "Account", acct.keyPrefix == "001",
			let contact = results["Contact"], contact.name == "Contact"
			else {
				XCTFail()
				return
			}
			exp.fulfill()
		}.catch {
			error in
			XCTFail("Failed to describe all. Error: \(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItFailsToDescribe() {
		// Given
		let type = "A Nonexistent Object"
		
		// When
		let exp = expectation(description: "Describe nonexistent object")
		salesforce.describe(type: type)
			.then {
				// Then
				desc -> () in
				XCTFail()
			}.catch {
				error in
				debugPrint(error)
				exp.fulfill()
		}
		waitForExpectations(timeout: 10.0, handler: nil)
		
	}
	
	func testThatItDescribesMultipleObjects() {
		
		// Given
		let types = ["Event", "Account", "Contact", "Lead", "Task"]
		
		// When 
		let exp = expectation(description: "Describe multiple objects")
		first {
			salesforce.describe(types: types)
		}.then {
			result -> () in
			XCTAssertEqual(result.count, types.count)
			XCTAssertEqual(result.map { $0.name }, types)
			exp.fulfill()
		}.catch {
			error in
			XCTFail("\(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItFailsToDescribesMultipleObjects() {
		
		// Given
		let types = ["Event", "XXXXXXXXX", "Contact", "Lead", "Task"]
		
		// When
		let exp = expectation(description: "Describe multiple objects")
		first {
			salesforce.describe(types: types)
			}.then {
				result -> () in
				XCTFail()
			}.catch {
				error in
				debugPrint(error)
				exp.fulfill()
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
}
