//
//  SalesforceAPITests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class SalesforceAPITests: XCTestCase {

	let creds = Credentials(
			accessToken: "ACCESS!TOKEN",
			instanceURL: NSURL(string: "https://na1.salesforce.com")!,
			identityURL: NSURL(string: "https://login.salesforce.com/id/00D50000000IZ3ZEAW/00550000001fg5OAAQ")!,
			refreshToken: "REFRESH!TOKEN"
	)

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
		
		// Next query result
		api = SalesforceAPI.NextQueryResult(path: "/services/data/v20.0/query/01gD0000002HU6KIAW-2000"
)
		endpoint = api.endpoint(credentials: creds)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			XCTAssertEqual(endpoint.HTTPMethod, "GET")
			XCTAssertNil(endpoint.HTTPBody)
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertNil(comps.queryItems)
			XCTAssertEqual(comps.path, "/services/data/v20.0/query/01gD0000002HU6KIAW-2000")
		}
		else {
			XCTFail()
		}
		
		// Create record
		api = SalesforceAPI.CreateRecord(type: "Contact", fields: [ "FirstName" : "Joe", "LastName" : "Jones"])
		endpoint = api.endpoint(credentials: creds)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			XCTAssertEqual(endpoint.HTTPMethod, "POST")
			//XCTAssertNil(endpoint.HTTPBody)
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertNil(comps.queryItems)
			XCTAssertEqual(comps.path, "/services/data/v\(SalesforceAPI.DefaultVersion)/sobjects/Contact/")
		}
		else {
			XCTFail()
		}
		
		// Read record
		api = SalesforceAPI.ReadRecord(type: "Contact", id: "SOME_ID", fields: ["FirstName", "LastName", "Phone"])
		endpoint = api.endpoint(credentials: creds, version: 21)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			XCTAssertEqual(endpoint.HTTPMethod, "GET")
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertEqual(url.valueForQueryItem("fields"), "FirstName,LastName,Phone")
			XCTAssertEqual(comps.path, "/services/data/v21.0/sobjects/Contact/SOME_ID")
		}
		else {
			XCTFail()
		}
		
		// ApexRest
		api = SalesforceAPI.ApexRest(method: .PATCH, path: "/MyApex/RestMethod", parameters: ["zip": "94321"], headers: ["My-Header-Field": "header-value"])
		endpoint = api.endpoint(credentials: creds)
		if let url = endpoint.URL, comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
			XCTAssertEqual(endpoint.HTTPMethod, "PATCH")
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("Authorization"), "Bearer ACCESS!TOKEN")
			XCTAssertEqual(endpoint.valueForHTTPHeaderField("My-Header-Field"), "header-value")
			XCTAssertEqual(comps.path, "/services/apexrest/MyApex/RestMethod")
		}
		else {
			XCTFail()
		}
		
		//TODO: remaining endpoints
	}
}
