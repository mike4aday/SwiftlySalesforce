//
//  Salesforce_ConfigurationTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class Salesforce_ConfigurationTests: XCTestCase {
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testThatItDecodesFromJSON1() {
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath"
		}
		"""
		let data = json.data(using: .utf8)!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		XCTAssertEqual(config.consumerKey, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(config.callbackURL, URL(string: "myScheme://myPath")!)
		XCTAssertEqual(config.authorizationURL.host!, Salesforce.Configuration.defaultAuthorizationHost)
		XCTAssertEqual(config.version, Salesforce.Configuration.defaultVersion)
	}
	
	func testThatItDecodesFromJSON2() {
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationHost": "test.salesforce.com"
		}
		"""
		let data = json.data(using: .utf8)!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		XCTAssertEqual(config.consumerKey, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(config.callbackURL, URL(string: "myScheme://myPath")!)
		XCTAssertEqual(config.authorizationURL.host!, "test.salesforce.com")
		XCTAssertEqual(config.authorizationURL.scheme!, "https")
		XCTAssertEqual(config.version, Salesforce.Configuration.defaultVersion)
	}
	
	func testThatItDecodesFromJSON3() {
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationHost": "test.salesforce.com",
			"version": "100.2"
		}
		"""
		let data = json.data(using: .utf8)!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		XCTAssertEqual(config.consumerKey, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(config.callbackURL, URL(string: "myScheme://myPath")!)
		XCTAssertEqual(config.authorizationURL.host!, "test.salesforce.com")
		XCTAssertEqual(config.authorizationURL.scheme!, "https")
		XCTAssertEqual(config.authorizationURL.queryItems!.count, 5)
		XCTAssertEqual(config.version, "100.2")
	}
	
	func testThatItDecodesFromJSON4() {
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationURL": "https://custom.my.salesforce.com/services/oauth2/authorize",
			"version": "100.2"
		}
		"""
		let data = json.data(using: .utf8)!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		XCTAssertEqual(config.consumerKey, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(config.callbackURL, URL(string: "myScheme://myPath")!)
		XCTAssertEqual(config.authorizationURL.host!, "custom.my.salesforce.com")
		XCTAssertEqual(config.authorizationURL.scheme!, "https")
		XCTAssertEqual(config.version, "100.2")
	}
	
	func testThatItDecodesFromJSON5() {
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationURL": "https://custom.my.salesforce.com/services/oauth2/authorize",
			"authorizationHost": "this.host.should.be.ignored",
			"authorizationParameters": {
				"Param1": "Value1",
				"Param2": "Value2"
			}
		}
		"""
		let data = json.data(using: .utf8)!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		XCTAssertEqual(config.consumerKey, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(config.callbackURL, URL(string: "myScheme://myPath")!)
		XCTAssertEqual(config.authorizationURL.host!, "custom.my.salesforce.com")
		XCTAssertEqual(config.authorizationURL.scheme!, "https")
		XCTAssertNil(config.authorizationURL.queryItems)
		XCTAssertEqual(config.version, Salesforce.Configuration.defaultVersion)
	}
	
	func testThatItDecodesFromJSON6() {
		
		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationHost": "custom.my.salesforce.com",
			"authorizationParameters": {
				"Param1": "Value1",
				"Param2": "Value2"
			},
			"version": "100.2"
		}
		"""
		let data = json.data(using: .utf8)!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		
		XCTAssertEqual(config.consumerKey, "YOUR CONSUMER KEY HERE")
		XCTAssertEqual(config.callbackURL, URL(string: "myScheme://myPath")!)
		XCTAssertEqual(config.authorizationURL.host!, "custom.my.salesforce.com")
		XCTAssertEqual(config.authorizationURL.scheme!, "https")
		XCTAssertEqual(config.authorizationURL.queryItems!.count, 7)
		XCTAssertEqual(config.version, "100.2")
	}
	
	func testThatItFailsToDecodeFromJSON1() {
		
		// JSON is missing consumer key
		let json = """
		{
			"callbackURL": "myScheme://myPath",
			"authorizationHost": "custom.my.salesforce.com",
			"authorizationParameters": {
				"Param1": "Value1",
				"Param2": "Value2"
			},
			"version": "100.2"
		}
		"""
		let data = json.data(using: .utf8)!
		
		do {
			let _ = try JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		}
		catch {
			// Should fail
			return
		}
	}
	
	func testThatItFailsToDecodeFromJSON2() {

		let json = """
		{
			"consumerKey": "YOUR CONSUMER KEY HERE",
			"callbackURL": "myScheme://myPath",
			"authorizationHost": "Bad Host Name",
			"version": "100.2"
		}
		"""
		let data = json.data(using: .utf8)!
		
		do {
			let _ = try JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		}
		catch {
			// Should fail
			return
		}
		XCTFail()
	}
}
