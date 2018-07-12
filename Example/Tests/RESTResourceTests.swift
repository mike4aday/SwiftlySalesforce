//
//  RESTResourceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class RESTResourceTests: XCTestCase {
    
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
    
	func testIdentity() {
		
		let req = try! RESTResource.identity(version: "41.0").asURLRequest(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, auth.identityURL.absoluteString + "?version=41.0")
		XCTAssertEqual(req.httpMethod, "GET")
		XCTAssertEqual(req.url!.queryItems(named: "version")!.first!.value!, "41.0")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
	}
	
	func testLimits() {
		
		let req = try! RESTResource.limits(version: "123").asURLRequest(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/data/v123/limits")
		XCTAssertEqual(req.httpMethod, "GET")
		XCTAssertNil(req.url!.queryItems)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
	}
	
	func testSmallFile() {
		
		let req = try! RESTResource.smallFile(url: nil, path: "path/to/my/photo.jpg", accept: "image/*").asURLRequest(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/path/to/my/photo.jpg")
		XCTAssertEqual(req.httpMethod, "GET")
		XCTAssertNil(req.url!.queryItems)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
	}
	
	func testApexGet() {
		
		let res = RESTResource.apex(method: "GET", path: "/MyRESTResource/test", parameters: ["id": "00112345"], body: nil, headers: ["header1": "value1"])
		let req  = try! res.asURLRequest(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/apexrest/MyRESTResource/test?id=00112345")
		XCTAssertEqual(req.httpMethod, "GET")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.url!.queryItems(named: "id")!.first!.value!, "00112345")
		XCTAssertEqual(req.value(forHTTPHeaderField: "header1")!, "value1")
	}
}
