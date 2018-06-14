//
//  TestUtils.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

@testable import SwiftlySalesforce

class TestUtils {
	
	static let shared = TestUtils()
	
	private init() {
		// Can't init
	}
	
	/*
	func createSalesforce(consumerKey: String, enrichedRedirectURL: URL) -> Salesforce {
		let callbackURL = URL(string: enrichedRedirectURL.absoluteString.components(separatedBy: "#")[0])!
		let connectedApp = ConnectedApp(consumerKey: consumerKey, callbackURL: callbackURL, loginDelegate: self, userID: "TEST USER ID", orgID: "TEST ORG ID")
		let authData = try! OAuth2Result(urlEncodedString: enrichedRedirectURL.fragment!)
		connectedApp.authData = authData
		return Salesforce(connectedApp: connectedApp)
	}
	*/
	
	func read(fileName: String, ofType: String = "json") -> Data? {
		guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: ofType) else {
			return nil
		}
		let url = URL(fileURLWithPath: path)
		return try? Data(contentsOf: url)
	}
}
