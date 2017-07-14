//
//  ConnectedAppTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
import Alamofire
@testable import SwiftlySalesforce

class ConnectedAppTests: XCTestCase, MockData, LoginDelegate {
	
	var consumerKey: String!
	var redirectURL: URL!
	var accessToken: String!
	var refreshToken: String!
	
	override func setUp() {
		super.setUp()
		let config = readPropertyList(fileName: "OAuth2")!
		consumerKey = config["ConsumerKey"] as! String
		redirectURL = URL(string: config["RedirectURL"] as! String)!
		accessToken = config["AccessToken"] as! String
		refreshToken = config["RefreshToken"] as! String
	}
	
	func testThatItFormsCorrectLoginURL() {
		
		// Given
		guard let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		let app = ConnectedApp(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self)
		
		// When
		guard let loginURL = try? app.loginURL() else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertNotNil(loginURL)
		XCTAssertEqual(loginURL.value(forQueryItem: "response_type"), "token")
		XCTAssertEqual(loginURL.value(forQueryItem: "client_id"), consumerKey)
		XCTAssertEqual(loginURL.value(forQueryItem: "redirect_uri"), redirectURL.absoluteString)
		XCTAssertEqual(loginURL.value(forQueryItem: "prompt"), "login consent")
		XCTAssertEqual(loginURL.value(forQueryItem: "display"), "touch")
	}
}
