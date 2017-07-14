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
	
	func testIdentityRequest() {
		
		// Given
		let authData = OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		
		// When
		guard let req = try? Resource.identity(version: "41.0").asURLRequest(authData: authData) else {
			return XCTFail()
		}
		
		// Then
		XCTAssertEqual(req.httpMethod, HTTPMethod.get.rawValue)
		XCTAssertEqual(req.url!.absoluteString, identityURL.absoluteString + "?version=41.0")
		XCTAssertEqual(req.url!.value(forQueryItem: "version"), "41.0")
	}
	
	func testRetrieveRequest() {
		
		// Given
		let authData = OAuth2Result(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		let type = "Account"
		let id = "12345"
		let fields = ["Id","Name","Custom1__c"]
		let version = "41.0"
		
		// When
		guard let req = try? Resource.retrieve(type: type, id: id, fields: fields, version: version).asURLRequest(authData: authData),
			let url = req.url,
			let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			return XCTFail()
		}
		
		// Then
		XCTAssertEqual(req.httpMethod, HTTPMethod.get.rawValue)
		XCTAssertEqual(url.path, "/services/data/v\(version)/sobjects/\(type)/\(id)")
		XCTAssert(components.queryItems!.count == 1)
		XCTAssert(components.queryItems![0].name == "fields")
		XCTAssert(components.queryItems![0].value!.contains("Id"))
		XCTAssert(components.queryItems![0].value!.contains("Name"))
		XCTAssert(components.queryItems![0].value!.contains("Custom1__c"))
	}
}
