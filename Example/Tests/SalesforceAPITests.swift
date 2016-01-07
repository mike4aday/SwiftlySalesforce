//
//  SalesforceAPITests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
import SwiftlySalesforce

class SalesforceAPITests: XCTestCase {

	let creds = Credentials(
			accessToken: "ACCESS!TOKEN",
			instanceURL: NSURL(string: "https://na1.salesforce.com")!,
			identityURL: NSURL(string: "https://login.salesforce.com/id/00D50000000IZ3ZEAW/00550000001fg5OAAQ")!,
			refreshToken: "REFRESH!TOKEN"
	)
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testEndpoints() {
		
		var api: SalesforceAPI
		var endpoint: NSMutableURLRequest
		
		// Identity
		api = SalesforceAPI.Identity
		endpoint = api.endpoint(credentials: creds)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			XCTAssertEqual(endpoint.HTTPMethod, "GET")
			XCTAssertNil(endpoint.HTTPBody)
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertNil(comps.queryItems)
			XCTAssertEqual(comps.path, "/id/00D50000000IZ3ZEAW/00550000001fg5OAAQ")
		}
		else {
			XCTFail()
		}
		
		// Limits
		api = SalesforceAPI.Limits
		endpoint = api.endpoint(credentials: creds)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			XCTAssertEqual(endpoint.HTTPMethod, "GET")
			XCTAssertNil(endpoint.HTTPBody)
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertNil(comps.queryItems)
			XCTAssertEqual(comps.path, "/services/data/v\(SalesforceAPI.DefaultVersion)/limits/")
		}
		else {
			XCTFail()
		}
		
		// Query
		let soql = "SELECT Id FROM Account LIMIT 10"
		api = SalesforceAPI.Query(soql: soql)
		endpoint = api.endpoint(credentials: creds)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			
			XCTAssertEqual(endpoint.HTTPMethod, "GET")
			XCTAssertNil(endpoint.HTTPBody)
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertEqual(comps.queryItems?.count, 1)
			XCTAssertEqual(comps.path, "/services/data/v\(SalesforceAPI.DefaultVersion)/query/")
			
			// Query string test
			if let queryItems = comps.queryItems {
				XCTAssert(queryItems.contains(NSURLQueryItem(name: "q", value: soql)))
			}
			else {
				XCTFail()
			}
		}
		else {
			XCTFail()
		}
		
		//TODO: remaining endpoints
	}
}
