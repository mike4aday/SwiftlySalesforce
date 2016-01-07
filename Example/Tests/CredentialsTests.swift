//
//  CredentialsTest.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
import SwiftlySalesforce

class CredentialsTest: XCTestCase {
	
	let accessToken = "00Dx0000000BB6a!AR8AQBM8J___9kLasZIRyRxZgQcN4HVi43aGcW0qW3JCzf5xdHHHHSoVim8FfJkZE___jaFbberKGk9a9AnYrvChG4qJbBo7" // Not a real access token
	let refreshToken = "5Aep8624iLX.Bq878ePDnPEgaXR9Oo__3JXkX_X4xRxb54_pZ_Xyj1dPEk8ajnw4Kr9ne7VXXVSIQ==" // Not a real refresh token
	let identityURL = NSURL(string: "https://login.salesforce.com/id/00Dx0000000BBBz/005x00000012W1H")!
	let instanceURL = NSURL(string: "https://na1.salesforce.com")!
	
	let encode: (String) -> (String) = {
		encodeMe in
		return encodeMe.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: ":/!=").invertedSet)!
	}

	func testInitWithDictionary() {
		
		let dict1: [String: AnyObject] = [
			"access_token" : accessToken
		]
		XCTAssertNil(Credentials(dictionary: dict1))
		
		let dict2 = [
			"access_token" : accessToken,
			"instance_url" : NSURL(string: "https://www.salesforce.com")!,
			"id" : identityURL
		]
		if let authResult = Credentials(dictionary: dict2) {
			XCTAssertEqual(authResult.accessToken, dict2["access_token"] as? String)
			XCTAssertNil(authResult.refreshToken)
			XCTAssertEqual(authResult.instanceURL, dict2["instance_url"] as? NSURL)
			XCTAssertEqual(authResult.identityURL, dict2["id"] as? NSURL)
		}
		else {
			XCTFail()
		}
		
		let dict3: [String: AnyObject] = [
			"access_token" : accessToken,
			"instance_url" : NSURL(string: "https://www.salesforce.com")!,
			"id" : identityURL,
			"refresh_token" : refreshToken
		]
		if let authResult = Credentials(dictionary: dict3) {
			XCTAssertEqual(authResult.accessToken, dict3["access_token"] as? String)
			XCTAssertEqual(authResult.refreshToken, dict3["refresh_token"] as? String)
			XCTAssertEqual(authResult.instanceURL, dict3["instance_url"] as? NSURL)
			XCTAssertEqual(authResult.identityURL, dict3["id"] as? NSURL)
		}
		else {
			XCTFail()
		}
	}
	
	func testInitWithCallbackURL() {
		
		// Sample callback URL
		var callbackURLString = "https://www.mysite.com/user_callback.jsp#access_token=\(encode(accessToken))&refresh_token=\(encode(refreshToken))&instance_url=\(encode(instanceURL.absoluteString))&id=\(encode(identityURL.absoluteString))&issued_at=1279448101616&signature=miQQQQ4sdQQiduBsvyRYPCDoqqhe43RRr1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate"
		
		let url = NSURL(string: callbackURLString)
		XCTAssertNotNil(url)
		
		if let authResult = Credentials(callbackURL: url!) {
			XCTAssertNotNil(authResult)
			XCTAssertEqual(instanceURL, authResult.instanceURL)
			XCTAssertEqual(identityURL, authResult.identityURL)
			XCTAssertEqual(accessToken, authResult.accessToken)
			XCTAssertNotNil(authResult.refreshToken)
			XCTAssertEqual(refreshToken, authResult.refreshToken)
			XCTAssertEqual("005x00000012W1H", authResult.userID)
		}
		else {
			XCTFail()
		}
		
		// Init failure - URL has no query string parameters
		callbackURLString = "https://www.mysite.com/user_callback.jsp=access_token=\(encode(accessToken))&refresh_token=\(encode(refreshToken))&instance_url=\(instanceURL.absoluteString)id=\(encode(identityURL.URLString))&issued_at=1279448101616&signature=miQQQQ4sdQQiduBsvyRYPCDoqqhe43RRr1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate"
		let creds = Credentials(callbackURL: NSURL(string: callbackURLString)!)
		XCTAssertNil(creds)
	}
	
	func testInitWithJSON() {
		
		// Sample JSON as string
		let jsonString = "{ \"id\":\"\(identityURL.URLString)\",\"issued_at\":\"1278448394422\",\"instance_url\":\"https://na1.salesforce.com\",\"signature\":\"SSSbLO/gBhmmyNUvN00ODBDFYHzakxONgqYtu+hDPsc=\",\"access_token\":\"\(accessToken)\",\"token_type\":\"Bearer\",\"scope\":\"id api refresh_token\"}"
		
		let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		XCTAssertNotNil(data)
		
		let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
		XCTAssertNotNil(json)
		
		let authResult = Credentials(json: json!, refreshToken: "EXISTING REFRESH TOKEN")
		XCTAssertNotNil(authResult)
		XCTAssertEqual(authResult!.accessToken, accessToken)
		XCTAssertEqual(authResult!.refreshToken, "EXISTING REFRESH TOKEN")
		XCTAssertEqual(authResult!.instanceURL, NSURL(string: "https://na1.salesforce.com"))
		XCTAssertEqual(authResult!.identityURL, identityURL)
		XCTAssertEqual(authResult!.userID, "005x00000012W1H")
	}
	
	func testToDictionary() {
		
		let callbackURLString = "https://www.mysite.com/user_callback.jsp#access_token=\(encode(accessToken))&refresh_token=\(encode(refreshToken))&instance_url=\(encode(instanceURL.absoluteString))&id=\(encode(identityURL.absoluteString))&issued_at=1279448101616&signature=miQQQQ4sdQQiduBsvyRYPCDoqqhe43RRr1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate"
		let creds = Credentials(callbackURL: NSURL(string: callbackURLString)!)!
		print(creds.instanceURL)
		let dict = creds.toDictionary()
		XCTAssertEqual(dict["access_token"] as? String, accessToken)
		XCTAssertEqual(dict["refresh_token"] as? String, refreshToken)
		XCTAssertEqual(dict["instance_url"] as? NSURL, instanceURL)
		XCTAssertEqual(dict["id"] as? NSURL, identityURL)
	}
}
