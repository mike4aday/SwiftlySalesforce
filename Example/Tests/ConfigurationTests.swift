//
//  ConfigurationTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 6/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ConfigurationTests: XCTestCase {
	
	let consumerKey = "CONSUMER_KEY"
	let callbackURL = URL(string: "hello://world")!
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatItInitsWithMinimumArgs() {
		
		let config = try! Configuration(consumerKey: consumerKey, callbackURL: callbackURL)
		let comps = URLComponents(url: config.authorizationURL, resolvingAgainstBaseURL: false)
		
		XCTAssertEqual(config.consumerKey, consumerKey)
		XCTAssertEqual(config.callbackURL, callbackURL)
		XCTAssertEqual(comps?.host, "login.salesforce.com")
		XCTAssertEqual(comps?.queryItems?.count, 5)
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "response_type"}).first?.value, "token")
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "client_id"}).first?.value, consumerKey)
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "redirect_uri"}).first?.value, callbackURL.absoluteString)
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "prompt"}).first?.value, "login consent")
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "display"}).first?.value, "touch")
		XCTAssertEqual(config.version, Configuration.defaultVersion)
	}
	
	func testThatItInitsWithAllArgs() {
		
		let authorizationHost = "myhost.salesforce.com"
		let authorizationParameters: [String: String] = ["Param1": "Value1", "Param2": "Value2", "response_type": "not_token"] // Note overriding "response_type" value
		let version = "v999.0"
		let config = try! Configuration(consumerKey: consumerKey, callbackURL: callbackURL, authorizationHost: authorizationHost, authorizationParameters: authorizationParameters, version: version)
		let comps = URLComponents(url: config.authorizationURL, resolvingAgainstBaseURL: false)
		
		XCTAssertEqual(config.consumerKey, consumerKey)
		XCTAssertEqual(config.callbackURL, callbackURL)
		XCTAssertEqual(comps?.host, authorizationHost)
		XCTAssertEqual(comps?.queryItems?.count, 7)
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "response_type"}).first?.value, "not_token")
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "client_id"}).first?.value, consumerKey)
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "redirect_uri"}).first?.value, callbackURL.absoluteString)
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "prompt"}).first?.value, "login consent")
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "display"}).first?.value, "touch")
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "Param1"}).first?.value, "Value1")
		XCTAssertEqual(comps?.queryItems?.filter({$0.name == "Param2"}).first?.value, "Value2")
		XCTAssertEqual(config.version, version)
	}
	
	func testThatItWontInitWithBadHostname() {
		
		let badHostname = "test . salesforce.com"
		
		do {
			let _ = try Configuration(consumerKey: consumerKey, callbackURL: callbackURL, authorizationHost: badHostname)
			XCTFail()
		}
		catch {
			// Expected
			debugPrint(error)
		}
	}
}
