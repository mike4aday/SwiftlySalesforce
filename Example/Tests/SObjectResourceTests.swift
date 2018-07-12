//
//  SObjectResourceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class SObjectResourceTests: XCTestCase {
    
	var auth: Authorization!
	
	override func setUp() {
		super.setUp()
		let accessToken = "ACCESS_TOKEN"
		let refreshToken = "REFRESH_TOKEN"
		let identityURL = URL(string: "https://login.salesforce.com/id/00Di0000000XXX3EAI/005i00000016PdaAAE")!
		let instanceURL = URL(string: "https://na15.salesforce.com")!
		auth = Authorization(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken, issuedAt: 123)
	}
    
    override func tearDown() {
        super.tearDown()
    }
    
	func testInsert() {
		let json = """
		{ "Name": "Smallbiz Co., Inc.", "BillingState": "CA" }
		"""
		let res = SObjectResource.insert(type: "Account", data: json.data(using: .utf8)!, version: "33.0")
		let req = try! res.asURLRequest(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/data/v33.0/sobjects/Account/")
		XCTAssertEqual(req.httpMethod, "POST")
		XCTAssertNil(req.url!.queryItems)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
	}
}
