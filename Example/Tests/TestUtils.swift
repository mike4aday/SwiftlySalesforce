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
		let callbackURL = URL(string: enrichedRedirectURL.absoluteString.components(separatedBy: "#")[0])!
		let connectedApp = ConnectedApp(consumerKey: consumerKey, callbackURL: callbackURL, loginDelegate: self, userID: "TEST USER ID", orgID: "TEST ORG ID")
		let authData = try! OAuth2Result(urlEncodedString: enrichedRedirectURL.fragment!)
		connectedApp.authData = authData
		return Salesforce(connectedApp: connectedApp)
	}
}
