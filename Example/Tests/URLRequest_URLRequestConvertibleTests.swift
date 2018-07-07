//
//  URLRequest_URLRequestConvertibleTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class URLRequest_URLRequestConvertibleTests: XCTestCase {
    
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
    
	func testThatItConverts() {
		
		let url = URL(string: "https://www.salesforce.com/path/here?q=SELECT+Id+FROM+Account&name=value")!
		var req = URLRequest(url: url)
		req.httpMethod = "PATCH"
		req.httpBody = "Hello World!".data(using: .utf8)
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.setValue("N/A", forHTTPHeaderField: "Authorization") // Should get overwritten
		req = try! req.asURLRequest(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, url.absoluteString.replacingOccurrences(of: "+", with: "%2B"))
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "application/json")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer ACCESS_TOKEN")
	}
}
