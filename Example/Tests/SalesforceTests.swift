//
//  SalesforceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
import PromiseKit
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase, MockData, LoginDelegate {
	
	var config: NSDictionary!
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		config = readPropertyList(fileName: "OAuth2")
		let consumerKey = config["ConsumerKey"] as! String
		let redirectURL = URL(string: config["RedirectURL"] as! String)!
		let accessToken = config["AccessToken"] as! String
		let refreshToken = config["RefreshToken"] as! String
		let identityURL = URL(string: config["IdentityURL"] as! String)!
		let instanceURL = URL(string: config["InstanceURL"] as! String)!
		let connectedApp = ConnectedApp(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self, storeKey: nil)
		let oauth2Result = OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		connectedApp.authData = oauth2Result
		salesforce = Salesforce(connectedApp: connectedApp)
	}
	
	func testThatItGetsIdentity() {
		let exp = expectation(description: "Identity")
		salesforce.identity()
			.then {
				identity -> () in
				debugPrint(identity)
				XCTAssertEqual(identity.userID, self.salesforce.connectedApp.authData!.userID)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItGetsLimits() {
		let exp = expectation(description: "limits")
		salesforce.limits()
			.then {
				limits -> () in
				XCTAssertTrue(limits.count > 20) // ~23 as of Winter '17
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItQueriesNoRecords() {
		let soql = "SELECT Id FROM Account WHERE CreatedDate > NEXT_WEEK"
		let exp = expectation(description: "Query")
		salesforce.query(soql: soql)
			.then {
				queryResult -> () in
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
	
	func testThatItRetrieves() {
		
		// Note: At least 1 Account record must be in the org
		
		// Given
		let type = "Account"
		let soql = "SELECT Id FROM \(type) ORDER BY Id LIMIT 1"
		
		// When
		let exp = expectation(description: "Retrieve \(type) record")
		salesforce.query(soql: soql)
			.then {
				(queryResult) -> Promise<Record> in
				self.salesforce.retrieve(type: type, id: queryResult.records[0].id!)
			}.then {
				// Then
				record -> () in
				XCTAssertEqual(type, record.type!)
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
				// Then
				result -> () in
				XCTFail()
			}.catch {
				error in
				exp.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testItInserts() {
		
		// Note: will insert records into org
		
		// Given
		let type = "Account"
		let fields = [ "Name" : "Megacorp, Inc.", "BillingPostalCode": "12345"]
		
		// When
		let exp = expectation(description: "Insert \(type) record")
		first {
			salesforce.insert(type: type, fields: fields)
			}.then {
				// Then
				id -> () in
				XCTAssertTrue(id.hasPrefix("001"))
				XCTAssertTrue(id.characters.count >= 15)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDescribes() {
		
		// Given
		let type = "Account"
		
		// When
		let exp = expectation(description: "Describe Account")
		salesforce.describe(type: type)
			.then {
				// Then
				(desc: ObjectDescription) -> () in
				XCTAssertEqual(desc.name, "Account")
				XCTAssertTrue(desc.fields!.count > 0)
				XCTAssertNotNil(desc.fields!["Type"])
				XCTAssertEqual(desc.fields!["Type"]?.type, "picklist")
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
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
		waitForExpectations(timeout: 5.0, handler: nil)
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
		waitForExpectations(timeout: 5.0, handler: nil)
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
		waitForExpectations(timeout: 5.0, handler: nil)
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
		waitForExpectations(timeout: 5.0, handler: nil)
	}
}
