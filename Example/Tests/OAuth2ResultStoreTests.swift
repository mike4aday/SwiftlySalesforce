//
//  OAuth2ResultStoreTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class OAuth2ResultStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItStoresOAuth2Result() {
		
		// Given
		let key = OAuth2ResultStore.Key(userID: "USER_ID", orgID: "ORG_ID", consumerKey: "CONSUMER_KEY")
		let saved = OAuth2Result(accessToken: "ACCESS_TOKEN", instanceURL: URL(string: "https://na7.salesforce.com")!, identityURL: URL(string: "https://login.salesforce.com/id/ORGID/USERID")!, refreshToken: nil)
		
		// When
		try! OAuth2ResultStore.store(key: key, value: saved)
		let retrieved = OAuth2ResultStore.retrieve(key: key)
		
		// Then
		XCTAssertTrue(saved == retrieved!)
	}
}
