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
    
	func testThatItAuthorizesNewUser() {
		let exp = expectation(description: "Authorizes new user via user-agent flow & Safari-hosted login form")
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString))
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1").done { 
			debugPrint($0)
			exp.fulfill()
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItDoesntAuthorizeNewUser() {
		let exp = expectation(description: "Does not authorize new user")
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString))
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1", options: [.dontAuthenticate]).done { _ in
			XCTFail("Shouldn't authorize")
		}.catch { (error) in
			if case Salesforce.Error.unauthorized = error {
				exp.fulfill()
			}
			else {
				XCTFail(error.localizedDescription)
			}
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItRefreshes() {
		let exp = expectation(description: "Refreshes access token")
		let userID = UUID().uuidString
		let orgID = UUID().uuidString
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: userID, organizationID: orgID))
		var oldAuth: Authorization?
		salesforce.query(soql: "SELECT Id,Name FROM Account LIMIT 1").then { (queryResult: QueryResult<Record>) -> Promise<Void> in
			oldAuth = salesforce.authorization!
			return salesforce.revokeAccessToken()
		}.then { _ in
			salesforce.query(soql: "SELECT Id,Name FROM Contact LIMIT 1", options: [.dontAuthenticate])
		}.done {_ in
			XCTAssertNotEqual(oldAuth, salesforce.authorization!)
			exp.fulfill()
		}.catch {error in
			XCTFail("\(error)")
		}
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItRevokes() {
		let exp = expectation(description: "Refreshes access token")
		let user = Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString)
		let salesforce = Salesforce(configuration: config, user: user)
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1").then { _ -> Promise<Void> in
			XCTAssertNotNil(salesforce.authorization)
			return salesforce.revoke()
		}.done {
			XCTAssertNil(salesforce.authorization)
			exp.fulfill()
		}.catch {
			XCTFail("\($0)")
		}
		waitForExpectations(timeout: 600, handler: nil)
	}
}
