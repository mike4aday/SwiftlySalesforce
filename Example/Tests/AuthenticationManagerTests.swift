//
//  AuthenticationManagerTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class AuthenticationManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
		AuthenticationManager.sharedInstance.credentials = nil
    }
    
    override func tearDown() {
        super.tearDown()
		AuthenticationManager.sharedInstance.credentials = nil
	}

    func testCredentialRetrievalPerformance() {
		let creds1 = Credentials(accessToken: "ACCESS_TOKEN", instanceURL: NSURL(string: "https://www.salesforce.com")!, identityURL: NSURL(string: "https://login.salesforce.com/id/00D50000000IZ3ZEAW/00550000001fg5OAAQ")!, refreshToken: "REFRESH_TOKEN")
        self.measureBlock {
			AuthenticationManager.sharedInstance.loginCompletedWithCredentials(creds1)
			let _ = AuthenticationManager.sharedInstance.credentials
        }
    }
	
	func testConfiguration() {
		let callbackURL = NSURL(string: "salesforce://authenticated")!
		let consumerKey = "CONSUMER_KEY"
		AuthenticationManager.sharedInstance.configureWithConsumerKey(consumerKey, callbackURL: callbackURL)
		XCTAssertEqual(AuthenticationManager.sharedInstance.consumerKey, consumerKey)
		XCTAssertEqual(AuthenticationManager.sharedInstance.callbackURL, callbackURL)
	}
}
