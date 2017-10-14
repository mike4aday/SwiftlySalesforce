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
	
	var salesforce: Salesforce!
	
	override func setUp() {
		
		super.setUp()
		
		let config = readPropertyList(fileName: "OAuth2")!
		let consumerKey = config["ConsumerKey"] as! String
		let redirectURLWithAuth = URL(string: config["RedirectURLWithAuthData"] as! String)!
		salesforce = TestUtils.shared.createSalesforce(consumerKey: consumerKey, enrichedRedirectURL: redirectURLWithAuth)
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
		salesforce.identity().then {
			identity -> () in
			XCTAssertEqual(identity.userID, self.salesforce.connectedApp.authData!.userID)
			XCTAssertEqual(identity.orgID, self.salesforce.connectedApp.authData!.orgID)
			exp.fulfill()
		}.catch {
			error in
			XCTFail(String(describing: error))
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
				XCTFail(String(describing: error))
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
				XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItRunsMultipleQueries() {
		
		let account = [ "Name": "Bit Player, Inc.", "BillingPostalCode": "02214"]
		let contact = ["FirstName": "Jason", "LastName": "Johnson"]
		let exp = expectation(description: "Run multiple queries")
		
		first {
			salesforce.insert(type: "Account", fields: account)
		}.then {
			(accountID: String) -> Promise<(String, String)> in
			return self.salesforce.insert(type: "Contact", fields: contact).then { (accountID, $0) }
		}.then {
			(accountID, contactID) -> Promise<[QueryResult<SObject>]> in
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
		
		let soql = "SELECT Id FROM Account ORDER BY Id LIMIT 1"
		let exp = expectation(description: "Retrieve Account record")
		
		salesforce.query(soql: soql)
			.then {
				(queryResult) -> Promise<SObject> in
				XCTAssertTrue(queryResult.records.count > 0)
				return self.salesforce.retrieve(type: "Account", id: queryResult.records[0].id)
			}.then {
				// Then
				(record: SObject) -> () in
				XCTAssertEqual("Account", record.type)
				exp.fulfill()
			}.catch {
				XCTFail(String(describing: $0))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItQueriesAndDecodes() {
		
		struct Account: Decodable {
			var attributes: RecordAttributes
			var id: String
			var name: String
			var lastModifiedDate: Date
			enum CodingKeys: String, CodingKey {
				case attributes = "attributes"
				case id = "Id"
				case name = "Name"
				case lastModifiedDate = "LastModifiedDate"
			}
		}
		
		struct Contact: Decodable {
			var attributes: RecordAttributes
			var id: String
			var firstName: String
			var lastName: String
			var createdDate: Date
			var account: Account?
			enum CodingKeys: String, CodingKey {
				case attributes
				case id = "Id"
				case firstName = "FirstName"
				case lastName = "LastName"
				case createdDate = "CreatedDate"
				case account = "Account"
			}
		}
		
		let exp = expectation(description: "Query and decode")
		let soql = "SELECT Id, FIRSTNAME, LastName, CreatedDate, Account.Id, Account.Name, Account.LastModifiedDate FROM Contact"
		
		salesforce.query(soql: soql).then {
			(queryResult: QueryResult<Contact>) -> () in
			for contact in queryResult.records {
				XCTAssertEqual(contact.attributes.type, "Contact")
				XCTAssertEqual(contact.attributes.id, contact.id)
				XCTAssertTrue(contact.attributes.id.hasPrefix("003"))
				if let account = contact.account {
					XCTAssertEqual(account.attributes.type, "Account")
					XCTAssertEqual(account.attributes.id, account.id)
					XCTAssertTrue(account.attributes.id.hasPrefix("001"))
				}
			}
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItFailsToRetrieve() {
		
		let type = "Account"
		let id = "001xxxxxxxxxxxxxxx"
		let exp = expectation(description: "Retrieve nonexistent \(type) record")
		
		first {
			salesforce.retrieve(type: type, id: id)
			}.then {
				// Then
				(result: QueryResult<SObject>) -> () in
				XCTFail()
			}.catch {
				error in
				exp.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItInserts() {
		
		// Note: will insert records into org
		
		let type = "Account"
		let fields = [ "Name" : "Megacorp, Inc.", "BillingPostalCode": "12345"]
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
			XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDeletes() {
		
		// Note: will insert records into org
		
		let type = "Account"
		let fields = [ "Name" : "Worldwide Stuff, Inc.", "BillingPostalCode": "44554"]
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
			(id: String) -> Promise<QueryResult<SObject>> in
			return self.salesforce.query(soql: "SELECT Id FROM \(type) WHERE Id = '\(id)'")
		}.then {
			// Then shoudn't be found
			(queryResult: QueryResult) -> Void in
			XCTAssert(queryResult.totalSize == 0)
			exp.fulfill()
		}.catch {
			error in
			XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDescribes() {
		
		let type = "Account"
		let exp = expectation(description: "Describe Account")
		
		salesforce.describe(type: type)
			.then {
				// Then
				(desc: ObjectMetadata) -> () in
				let fields = Dictionary(items: desc.fields!) { $0.name }
				XCTAssertEqual(desc.name, "Account")
				XCTAssertTrue(fields.count > 0)
				XCTAssertNotNil(fields["Type"])
				XCTAssertEqual(fields["Type"]!.type, "picklist")
				exp.fulfill()
			}.catch {
				error in
				XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDescribesAll() {
		
		let exp = expectation(description: "Describe All (Describe Global)")
		
		salesforce.describeAll()
			.then {
				(result: [ObjectMetadata]) -> () in
				let objDescs = Dictionary(items: result) { $0.name }
				guard let acct = objDescs["Account"], acct.name == "Account", acct.keyPrefix == "001",
					let contact = objDescs["Contact"], contact.name == "Contact"
					else {
						XCTFail()
						return
				}
				exp.fulfill()
			}.catch {
				error in
				XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItFailsToDescribe() {

		let type = "A Nonexistent Object"
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
