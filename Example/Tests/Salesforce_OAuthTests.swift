//
//  Salesforce_OAuthTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class Salesforce_OAuthTests: XCTestCase {
	
	var config: Salesforce.Configuration!
	
    override func setUp() {
        super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testThatItAuthorizesNewUser() {
		let exp = expectation(description: "Authorizes new user via user-agent flow & Safari-hosted login form")
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString))
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1").done { 
			debugPrint($0)
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItDoesntAuthorizeNewUser() {
		let exp = expectation(description: "Does not authorize new user")
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString))
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1", options: [.dontAuthenticate]).done { _ in
			XCTFail("Shouldn't authorize")
		}.catch { (error) in
			guard case Salesforce.Error.unauthorized = error else {
				XCTFail(error.localizedDescription)
				return
			}
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItRefreshes() {
		
		let exp = expectation(description: "Refreshes access token")
		let userID = UUID().uuidString
		let orgID = UUID().uuidString
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: userID, organizationID: orgID))
		
		first {
			salesforce.query(soql: "SELECT Id,Name FROM Account LIMIT 1")
		}.then { (queryResult: QueryResult<SObject>) -> Promise<Authorization> in
			let oldAuth = salesforce.authorization!
			return salesforce.revokeAccessToken().map { oldAuth }
		}.then { oldAuth -> Promise<Authorization> in
			salesforce.query(soql: "SELECT Id,Name FROM Contact LIMIT 1", options: [.dontAuthenticate]).map { _ in oldAuth }
		}.done { oldAuth in
			XCTAssertNotEqual(oldAuth, salesforce.authorization!)
		}.catch {
			XCTFail($0.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItRevokes() {
		
		let exp = expectation(description: "Revoke tokens")
		let user = Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString)
		let salesforce = Salesforce(configuration: config, user: user)
		
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1").then { _ -> Promise<Void> in
			XCTAssertNotNil(salesforce.authorization)
			return salesforce.revoke()
		}.done {
			XCTAssertNil(salesforce.authorization)
		}.catch {
			XCTFail($0.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 600, handler: nil)
	}
}
