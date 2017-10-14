//
//  ConnectedAppTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ConnectedAppTests: XCTestCase, MockData, LoginDelegate {
	
	var consumerKey: String!
	var salesforce: Salesforce!
	
	override func setUp() {
		
		super.setUp()
		
		let config = readPropertyList(fileName: "OAuth2")!
		let redirectURLWithAuth = URL(string: config["RedirectURLWithAuthData"] as! String)!
		
		consumerKey = config["ConsumerKey"] as! String
		salesforce = TestUtils.shared.createSalesforce(consumerKey: consumerKey, enrichedRedirectURL: redirectURLWithAuth)
	}
	
	func testThatItFormsCorrectLoginURL() {
		
		let app = salesforce.connectedApp
		let loginURL = try! app.loginURL()
		
		XCTAssertNotNil(loginURL)
		XCTAssertEqual(loginURL.value(forQueryItem: "response_type"), "token")
		XCTAssertEqual(loginURL.value(forQueryItem: "client_id"), salesforce.connectedApp.consumerKey)
		XCTAssertEqual(loginURL.value(forQueryItem: "redirect_uri"), salesforce.connectedApp.redirectURL.absoluteString)
		XCTAssertEqual(loginURL.value(forQueryItem: "prompt"), "login consent")
		XCTAssertEqual(loginURL.value(forQueryItem: "display"), "touch")
	}
	
	func testInstanceVars() {
		
		let app = salesforce.connectedApp
		
		XCTAssertEqual(app.orgID, "00Di0000000bcK3EAI")
		XCTAssertEqual(app.userID, "005i00000016PdaAAE")
		XCTAssertEqual(app.instanceURL, URL(string: "https://na88.salesforce.com")!)
	}
}
