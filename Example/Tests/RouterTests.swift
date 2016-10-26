//
//  RouterTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class RouterTests: XCTestCase, MockOAuth2Data {
	
	var authData: AuthData = AuthData(accessToken: "ACCESS_TOKEN", instanceURL: URL(string: "https://na15.salesforce.com")!, identityURL: URL(string: "https://login.salesforce.com/id/00Di0000000XXX3EAI/005i00000016PdaAAE")!, refreshToken: "REFRESH_TOKEN")
	
	func testThatIdentityRequestBuildsOK() {
		
		// Given
		
		// When
		guard let req = try? Router.identity(authData: authData, version: "36.0").asURLRequest(), let url = req.url else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertNotNil(req)
		XCTAssertEqual(req.httpMethod, HTTPMethod.get.rawValue)
		XCTAssertEqual(url.value(forQueryItem: "version"), "36.0")
		XCTAssertEqual(authData.identityURL.path, url.path)
	}
	
	func testThatLimitsRequestBuildsOK() {
		
		// Given
		
		// When
		guard let req = try? Router.limits(authData: authData, version: "36.0").asURLRequest(), let url = req.url else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertNotNil(req)
		XCTAssertEqual(req.httpMethod, HTTPMethod.get.rawValue)
		XCTAssertEqual("https://na15.salesforce.com/services/data/v36.0/limits", url.absoluteString)
	}
}
