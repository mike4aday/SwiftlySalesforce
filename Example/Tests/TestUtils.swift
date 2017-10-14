//
//  TestUtils.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

@testable import SwiftlySalesforce

class TestUtils: LoginDelegate {
	
	static let shared = TestUtils()
	
	private init() {
		// Can't init
	}
	
	func createSalesforce(consumerKey: String, enrichedRedirectURL: URL) -> Salesforce {
		let redirectURL = URL(string: enrichedRedirectURL.absoluteString.components(separatedBy: "#")[0])!
		let key = OAuth2ResultStore.Key(userID: "TEST_USER_ID", orgID: "TEST_ORG_ID", consumerKey: consumerKey)
		let connectedApp = ConnectedApp(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self, storeKey: key)
		let authData = try! OAuth2Result(urlEncodedString: enrichedRedirectURL.fragment!)
		connectedApp.authData = authData
		return Salesforce(connectedApp: connectedApp)
	}
}
