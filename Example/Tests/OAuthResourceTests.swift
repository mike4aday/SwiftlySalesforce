//
//  OAuthResourceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class OAuthResourceTests: XCTestCase {
	
	var config: Salesforce.Configuration!
	var auth: Authorization!
	
	override func setUp() {
		super.setUp()
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationHost": "test.salesforce.com"
		}
		"""
		let data = json.data(using: .utf8)!
		config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		let accessToken = "ACCESS_TOKEN"
		let refreshToken = "REFRESH_TOKEN"
		let identityURL = URL(string: "https://login.salesforce.com/id/00Di0000000XXX3EAI/005i00000016PdaAAE")!
		let instanceURL = URL(string: "https://na15.salesforce.com")!
		auth = Authorization(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken, issuedAt: 123)
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testRefreshAccessToken() {
		
		let res = OAuthResource.refreshAccessToken(authorizationURL: config.authorizationURL, consumerKey: config.consumerKey)
		let req = try! res.asURLRequest(with: auth)
		let body = req.httpBody!
		var comps = URLComponents(string: "")!
		comps.percentEncodedQuery = String(data: body, encoding: .utf8)
		
		XCTAssertEqual(req.url!.absoluteString, "https://test.salesforce.com/services/oauth2/token")
		XCTAssertEqual(req.httpMethod, "POST")
		XCTAssertNil(req.url!.queryItems)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), URLRequest.MIMEType.urlEncoded.rawValue)
		XCTAssertEqual(comps.queryItems!.filter({ $0.name == "format" }).first!.value, "json")
		XCTAssertEqual(comps.queryItems!.filter({ $0.name == "grant_type" }).first!.value, "refresh_token")
		XCTAssertEqual(comps.queryItems!.filter({ $0.name == "client_id" }).first!.value, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(comps.queryItems!.filter({ $0.name == "refresh_token" }).first!.value, auth.refreshToken!)
	}
	
	func testRevokeAccessToken() {
		
		let res = OAuthResource.revokeAccessToken(authorizationURL: config.authorizationURL)
		let req = try! res.asURLRequest(with: auth)
		let body = req.httpBody!
		var comps = URLComponents(string: "")!
		comps.percentEncodedQuery = String(data: body, encoding: .utf8)
		
		XCTAssertEqual(req.url!.absoluteString, "https://test.salesforce.com/services/oauth2/revoke")
		XCTAssertEqual(req.httpMethod, "POST")
		XCTAssertNil(req.url!.queryItems)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), URLRequest.MIMEType.urlEncoded.rawValue)
		XCTAssertEqual(comps.queryItems!.filter({ $0.name == "token" }).first!.value, auth.accessToken)
	}
	
	func testRevokeRefreshToken() {
		
		let res = OAuthResource.revokeRefreshToken(authorizationURL: config.authorizationURL)
		let req = try! res.asURLRequest(with: auth)
		let body = req.httpBody!
		var comps = URLComponents(string: "")!
		comps.percentEncodedQuery = String(data: body, encoding: .utf8)
		
		XCTAssertEqual(req.url!.absoluteString, "https://test.salesforce.com/services/oauth2/revoke")
		XCTAssertEqual(req.httpMethod, "POST")
		XCTAssertNil(req.url!.queryItems)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), URLRequest.MIMEType.urlEncoded.rawValue)
		XCTAssertEqual(comps.queryItems!.filter({ $0.name == "token" }).first!.value, auth.refreshToken!)
	}
}
