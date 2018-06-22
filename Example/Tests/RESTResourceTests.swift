//
//  ResourceTests.swift
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
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testDescribe() {
		
		let req = try! RESTResource.describe(type: "Account", version: "99.3").request(with: auth)
		
		XCTAssertEqual(req.httpMethod, URLRequest.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/data/v99.3/sobjects/Account/describe")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), URLRequest.MIMEType.urlEncoded.rawValue)
	}
	
	func testIdentity() {
		
		let req = try! RESTResource.identity(version: "41.0").request(with: auth)
		
		XCTAssertEqual(req.httpMethod, URLRequest.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.url!.absoluteString, auth.identityURL.absoluteString + "?version=41.0")
		XCTAssertEqual(req.url!.queryItems(named: "version")!.first!.value!, "41.0")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), URLRequest.MIMEType.urlEncoded.rawValue)
	}
	
	func testLimits() {
		
		let req = try! RESTResource.limits(version: "123").request(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/data/v123/limits")
		XCTAssertEqual(req.httpMethod, URLRequest.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
	}
	
	func testRetrieve() {
		
		let type = "Account"
		let id = "12345"
		let fields = ["Id","Name","Custom1__c"]
		let version = "41.0"
		let req = try! RESTResource.retrieve(type: type, id: id, fields: fields, version: version).request(with: auth)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/data/v41.0/sobjects/Account/12345?fields=Id,Name,Custom1__c")
		XCTAssertEqual(req.httpMethod, URLRequest.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
		XCTAssertEqual(req.url!.queryItems(named: "fields")!.first!.value, "Id,Name,Custom1__c")
	}
	
	func testApexGet() {
		
		let req = try! RESTResource.apex(method: .get, path: "/MyRESTResource/test", queryParameters: ["id" : "00112345"], body: nil, contentType: "application/x-www-form-urlencoded; charset=utf-8", headers: nil).request(with: auth)

		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/apexrest/MyRESTResource/test?id=00112345")
		XCTAssertEqual(req.httpMethod, URLRequest.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
		XCTAssertEqual(req.url!.queryItems(named: "id")!.first!.value!, "00112345")
	}
}
