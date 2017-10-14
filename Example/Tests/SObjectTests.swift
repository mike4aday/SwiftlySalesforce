//
//  SObjectTests.swift
//  SwiftlySalesforce_Tests
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class SObjectTests: XCTestCase, MockData, LoginDelegate {
	
	var salesforce: Salesforce!

    override func setUp() {
		
        super.setUp()
		
		let config = readPropertyList(fileName: "OAuth2")!
		let consumerKey = config["ConsumerKey"] as! String
		let redirectURLWithAuth = URL(string: config["RedirectURLWithAuthData"] as! String)!
		let redirectURL = URL(string: redirectURLWithAuth.absoluteString.components(separatedBy: "#")[0])!
		let key = OAuth2ResultStore.Key(userID: "TEST_USER_ID", orgID: "TEST_ORG_ID", consumerKey: consumerKey)
		let connectedApp = ConnectedApp(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self, storeKey: key)
		
		if let authData = OAuth2ResultStore.retrieve(key: key) {
			connectedApp.authData = authData
		}
		else {
			let authData = try! OAuth2Result(urlEncodedString: redirectURLWithAuth.fragment!)
			connectedApp.authData = authData
			try? OAuth2ResultStore.store(key: key, value: authData)
		}
		salesforce = Salesforce(connectedApp: connectedApp)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testThatItDecodesAccount() {
		
		let soql = "SELECT Id, Name, CreatedDate, LastModifiedDate, Website FROM Account"
		let exp = expectation(description: "Account query")
		
		salesforce.query(soql: soql).then {
			
			(queryResult: QueryResult) -> () in
			for record in queryResult.records {
				
				let name: String? = try record.value(named: "Name")
				XCTAssertEqual(name, try record.string(named: "Name"))
				
				do {
					let _ = try record.uint(named: "Name")
					XCTFail("Should have failed to decode a string as a UInt")
				}
				catch {
					// Should throw error; "Name" is not a UInt
				}
				
				if let website = try record.url(named: "Website"), let website2: URL = try record.value(named: "Website") {
					XCTAssertEqual(website, website2)
				}
			}
			exp.fulfill()
		}.catch {
			error in
			XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
    func testThatItDecodesSubquery() {
		
		let soql = "SELECT Id, Name, CreatedDate, LastModifiedDate, Website, (SELECT Id, Name, CreatedDate, LastModifiedDate FROM Contacts) FROM Account"
		let exp = expectation(description: "Account query with contacts sub-query")
		
		salesforce.query(soql: soql).then {
			(queryResult: QueryResult) -> () in
			for record in queryResult.records {
				if let contacts = try record.subqueryResult(named: "Contacts") {
					debugPrint(contacts)
					XCTAssertTrue(contacts.totalSize > 0)
					XCTAssertNotNil(try contacts.records[0].string(named: "Id"))
					XCTAssertEqual(try contacts.records[0].string(named: "Id"), contacts.records[0].id)
					XCTAssertNotNil(try contacts.records[0].date(named: "LastModifiedDate"))
				}
			}
			exp.fulfill()
		}.catch {
			error in
			XCTFail(String(describing: error))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
}
