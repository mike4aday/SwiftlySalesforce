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
	var redirectURL: URL!
	var authData: OAuth2Result!
	
	override func setUp() {
		
		super.setUp()
		
		let config = readPropertyList(fileName: "OAuth2")!
		let redirectURLWithAuth = URL(string: config["RedirectURLWithAuthData"] as! String)!
		
		consumerKey = config["ConsumerKey"] as! String
		redirectURL = URL(string: redirectURLWithAuth.absoluteString.components(separatedBy: "#")[0])!
		authData = try! OAuth2Result(urlEncodedString: redirectURLWithAuth.fragment!)
	}
	
	func testThatItFormsCorrectLoginURL() {
		
		let app = ConnectedApp(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self)
		let loginURL = try! app.loginURL()
		
		XCTAssertNotNil(loginURL)
		XCTAssertEqual(loginURL.value(forQueryItem: "response_type"), "token")
		XCTAssertEqual(loginURL.value(forQueryItem: "client_id"), consumerKey)
		XCTAssertEqual(loginURL.value(forQueryItem: "redirect_uri"), redirectURL.absoluteString)
		XCTAssertEqual(loginURL.value(forQueryItem: "prompt"), "login consent")
		XCTAssertEqual(loginURL.value(forQueryItem: "display"), "touch")
	}
}
