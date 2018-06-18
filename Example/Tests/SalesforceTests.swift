//
//  Salesforce+RequestTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 6/15/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase {
	
	struct ConfigFile: Decodable {
		let consumerKey: String
		let redirectURL: String
	}
	
	var config: Configuration!
	
    override func setUp() {
        super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let configFile = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(ConfigFile.self, from: data)
		let url = URL(string: configFile.redirectURL)!
		config = try! Configuration(consumerKey: configFile.consumerKey, callbackURL: url)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testThatItAuthorizesNewUser() {
		let exp = expectation(description: "Authorizes new user via user-agent flow & Safari-hosted login form")
		// Create Salesforce with user guaranteed not to exist
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString))
		salesforce.authorize().done {
			debugPrint($0)
			exp.fulfill()
		}.catch { (error) in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
	
	func testThatItDoesntAuthorizeNewUser() {
		let exp = expectation(description: "Does not authorize new user")
		// Create Salesforce with user guaranteed not to exist
		let salesforce = Salesforce(configuration: config, user: Salesforce.User(userID: UUID().uuidString, organizationID: UUID().uuidString))
		salesforce.query(soql: "SELECT Id FROM Account LIMIT 1", shouldAuthorize: false).done { _ in
			XCTFail("Shouldn't authorize")
		}.catch { (error) in
			if case Salesforce.Error.authenticationRequired = error {
				exp.fulfill()
			}
			else {
				XCTFail(error.localizedDescription)
			}
		}
		waitForExpectations(timeout: 10.0*60, handler: nil)
	}
}
