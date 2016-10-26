//
//  SalesforceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase, MockOAuth2Data, LoginDelegate {
	
	var window: UIWindow?
	
	override func setUp() {
		
		super.setUp()
		
		guard let accessToken = accessToken, let refreshToken = refreshToken, let instanceURL = instanceURL, let identityURL = identityURL, let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		salesforce.authManager.authData = AuthData(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		salesforce.authManager.configuration = AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self)
	}
	
	func testThatItGetsIdentity() {
		
		// Given
		
		// When
		let exp = expectation(description: "Identity")
		salesforce.identity()
			.then {
				// Then
				userInfo -> () in
				debugPrint(userInfo)
				XCTAssertEqual(userInfo.userID!, salesforce.authManager.authData?.userID!)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItGetsLimits() {
		
		// Given
		
		// When
		let exp = expectation(description: "Limits")
		salesforce.limits()
			.then {
				// Then
				limits -> () in
				debugPrint(limits)
				XCTAssertTrue(limits.count > 20) // ~23 as of Winter '17
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 7.0, handler: nil)
	}
	
	func testThatItQueries() {
		
		// Given
		let soql = "SELECT Id FROM Account WHERE CreatedDate > NEXT_WEEK"
		
		// When
		let exp = expectation(description: "Query")
		salesforce.query(soql: soql)
			.then {
				// Then
				queryResult -> () in
				debugPrint(queryResult)
				XCTAssertEqual(queryResult.records.count, 0)
				XCTAssertTrue(queryResult.isDone)
				XCTAssertNil(queryResult.nextRecordsPath)
				exp.fulfill()
			}.catch {
				error in
				XCTFail("\(error)")
		}
		waitForExpectations(timeout: 5.0, handler: nil)

	}
}
