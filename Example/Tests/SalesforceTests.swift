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
		let key = OAuth2ResultStore.Key(userID: "TEST_USER_ID", orgID: "TEST_ORG_ID", consumerKey: consumerKey)
		let connectedApp = ConnectedApp(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self, storeKey: key)

		if let authData = OAuth2ResultStore.retrieve(key: key) {
			connectedApp.authData = authData
		}
		else {
			let accessToken = config["AccessToken"] as! String
			let refreshToken = config["RefreshToken"] as! String
			let identityURL = URL(string: config["IdentityURL"] as! String)!
			let instanceURL = URL(string: config["InstanceURL"] as! String)!
			connectedApp.authData = OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		}
		salesforce = Salesforce(connectedApp: connectedApp)
	}
	
	override func tearDown() {
		
		super.tearDown()
		// Uncomment lines below to force refresh with each request
		//let consumerKey = config["ConsumerKey"] as! String
		//let key = OAuth2ResultStore.Key(userID: "TEST_USER_ID", orgID: "TEST_ORG_ID", consumerKey: consumerKey)
		//try! OAuth2ResultStore.clear(key: key)
	}
	
	func testThatItGetsIdentity() {
		let exp = expectation(description: "Identity")
		salesforce.identity()
			.then {
				identity -> () in
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
	
	func testThatItRunsMultipleQueries() {
		
		// Given
		let account = [ "Name": "Bit Player, Inc.", "BillingPostalCode": "02214"]
		let contact = ["FirstName": "Jason", "LastName": "Johnson"]
		
		let exp = expectation(description: "Run multiple queries")
		first {
			salesforce.insert(type: "Account", fields: account)
		}.then {
			(accountID: String) -> Promise<(String, String)> in
			return self.salesforce.insert(type: "Contact", fields: contact).then { (accountID, $0) }
		}.then {
			(accountID, contactID) -> Promise<[QueryResult]> in
			let q1 = "SELECT Id FROM Account WHERE Id = '\(accountID)'"
			let q2 = "SELECT Id FROM Contact WHERE Id = '\(contactID)'"
			return self.salesforce.query(soql: [q1, q2])
		}.then {
			(queryResults: [QueryResult]) -> Void in
			XCTAssert(queryResults.count == 2)
			XCTAssert(queryResults[0].totalSize == 1)
			XCTAssert(queryResults[1].totalSize == 1)
			exp.fulfill()
		}.catch {
			XCTFail($0.localizedDescription)
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
	
	func testItDeletes() {
		
		// Note: will insert records into org
		
		// Given
		let type = "Account"
		let fields = [ "Name" : "Worldwide Stuff, Inc.", "BillingPostalCode": "44554"]
		
		// When
		let exp = expectation(description: "Delete \(type) record")
		first {
			// Insert it
			salesforce.insert(type: type, fields: fields)
		}.then {
			// Delete it
			(id: String) -> Promise<String> in
			return self.salesforce.delete(type: type, id: id).then { id }
		}.then {
			// Try to query it
			(id: String) -> Promise<QueryResult> in
			return self.salesforce.query(soql: "SELECT Id FROM \(type) WHERE Id = '\(id)'")
		}.then {
			// Then shoudn't be found
			(queryResult: QueryResult) -> Void in
			XCTAssert(queryResult.totalSize == 0)
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
				XCTFail(error.localizedDescription)
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
	
	func testThatItFetchesImage() {
		let exp = expectation(description: "Fetch photo for user")
		first {
			salesforce.identity()
		}.then {
			// Retrieve photo
			(identity: Identity) -> Promise<UIImage> in
			guard let url = identity.photoURL else {
				throw NSError()
			}
			return self.salesforce.fetchImage(url: url)
		}.then {
			(image: UIImage) -> Void in
			XCTAssert(image.size.width > 0)
			XCTAssert(image.size.height > 0)
			exp.fulfill()
		}.catch {
			(error: Error) in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
}
