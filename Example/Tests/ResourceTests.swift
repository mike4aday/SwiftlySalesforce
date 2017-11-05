//
//  ResourceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ResourceTests: XCTestCase {
	
	let accessToken = "ACCESS_TOKEN"
	let refreshToken = "REFRESH_TOKEN"
	let identityURL = URL(string: "https://login.salesforce.com/id/00Di0000000XXX3EAI/005i00000016PdaAAE")!
	let instanceURL = URL(string: "https://na15.salesforce.com")!
	
	func testIdentity() {
		
		let authData = OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		let req = try! Resource.identity(version: "41.0").asURLRequest(authData: authData)
		
		XCTAssertEqual(req.httpMethod, Resource.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.url!.absoluteString, identityURL.absoluteString + "?version=41.0")
		XCTAssertEqual(req.url!.value(forQueryItem: "version"), "41.0")
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
	}
	
	func testRetrieve() {
		
		let authData = OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		let type = "Account"
		let id = "12345"
		let fields = ["Id","Name","Custom1__c"]
		let version = "41.0"
		let req = try! Resource.retrieve(type: type, id: id, fields: fields, version: version).asURLRequest(authData: authData)
		
		XCTAssertEqual(req.url!.absoluteString, "https://na15.salesforce.com/services/data/v41.0/sobjects/Account/12345?fields=Id,Name,Custom1__c")
		XCTAssertEqual(req.httpMethod, Resource.HTTPMethod.get.rawValue)
		XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization")!, "Bearer ACCESS_TOKEN")
	}
}
