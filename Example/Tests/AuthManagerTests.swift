//
//  AuthManagerTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class AuthManagerTests: XCTestCase, MockOAuth2Data, LoginDelegate {
	
	var window: UIWindow?
	
	func testThatItRefreshes() {
		
		// Given
		guard let refreshToken = refreshToken, let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		let oldAccessToken = accessToken
		let authMgr = AuthManager(configuration: AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self))
		
		// When
		let exp = expectation(description: "Refresh token")
		authMgr.refresh(refreshToken: refreshToken)
		.then {
			// Then
			authData -> () in
			debugPrint(authData)
			XCTAssertNotEqual(oldAccessToken, authData.accessToken)
			exp.fulfill()
		}.catch {
			error in
			XCTFail("\(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItFormsCorrectLoginURL() {
		
		// Given
		guard let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		let authMgr = AuthManager(configuration: AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self))
		
		// When
		guard let loginURL = try? authMgr.loginURL() else {
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
