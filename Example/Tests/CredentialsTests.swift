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
	let refreshToken = "5Aep8624iLX.Bq87_!!__PEgaXR9Oo__3JXkX_X4xRxb54_pZ_Xyj1dPEk8ajnw4Kr9ne7VXXVSIQ==" // Not a real refresh token
	let identityURL = NSURL(string: "https://login.salesforce.com/id/00Dx0000000BBBz/005x00000012W1H")!
	let instanceURL = NSURL(string: "https://na1.salesforce.com")!
	
	let encode: (String) -> (String) = {
		encodeMe in
		return encodeMe.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: ":/!=").invertedSet)!
	}
	
	func testDesignatedInitializer() {
		
		let creds = Credentials(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		XCTAssertEqual(creds.accessToken, self.accessToken)
		XCTAssertEqual(creds.refreshToken!, self.refreshToken)
		XCTAssertEqual(creds.identityURL, self.identityURL)
		XCTAssertEqual(creds.instanceURL, self.instanceURL)
	}
	
	func testInitWithDictionary() {
		
		// Empty dictionary as argument
		let dict1 = [String: AnyObject]()
		XCTAssertNil(Credentials(dictionary: dict1))
		
		// "Insufficient" dictionary as argument
		let dict2 = [
			"access_token" : "",
			"refresh_token" : self.refreshToken,
		]
		XCTAssertNil(Credentials(dictionary: dict2))
		
		// Dictionary without refresh token
		let dict3 = [
			"access_token" : self.accessToken,
			"instance_url" : self.instanceURL,
			"id" : self.identityURL
		]
		let creds3 = Credentials(dictionary: dict3)
		XCTAssertNotNil(creds3)
		XCTAssertNil(creds3?.refreshToken)
		
		// Dictionary with refresh token
		let dict4 = [
			"access_token" : self.accessToken,
			"refresh_token" : self.refreshToken,
			"instance_url" : self.instanceURL,
			"id" : self.identityURL
		]
		let creds4 = Credentials(dictionary: dict4)
		XCTAssertNotNil(creds4)
		XCTAssertNotNil(creds4?.refreshToken)
		
		// Invalid dictionary
		let dict5: [String: AnyObject] = ["Some Name": "Some Value"]
		XCTAssertNil(Credentials(dictionary: dict5))
	}
	
	func testWithURLEncodedString() {
		
		let callbackURL = NSURL(string: "https://www.mysite.com/user_callback.jsp#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https%3A%2F%2Fna1.salesforce.com&id=https%3A%2F%2Flogin.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate")
		
		guard let url = callbackURL, fragment = url.fragment, creds = Credentials(URLEncodedString: fragment) else {
			XCTFail()
			return
		}
		
		// Check for URL-decoded Credentials member values
		XCTAssertEqual(creds.accessToken, "00Dx0000000BV7z!AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8")
		XCTAssertEqual(creds.refreshToken, "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ==")
		XCTAssertEqual(creds.instanceURL, NSURL(string: "https://na1.salesforce.com")!)
		XCTAssertEqual(creds.identityURL, NSURL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
		
		guard let creds2 = Credentials(URLEncodedString: fragment, refreshToken: "REFRESH_TOKEN") else {
			XCTFail()
			return
		}
		XCTAssertEqual(creds2.refreshToken, "REFRESH_TOKEN")
		
		// Test equality operator
		let creds3 = Credentials(URLEncodedString: fragment, refreshToken: "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ==")
		XCTAssertTrue(creds3 == creds)
		
		// Test user ID getter
		XCTAssertEqual(creds.userID, "005x00000012Q9P")
		
		// Test conversion to dictionary
		let dict = creds.toDictionary()
		guard let instanceURL = dict["instance_url"] as? NSURL, identityURL = dict["id"] as? NSURL, accessToken = dict["access_token"] as? String, refreshToken = dict["refresh_token"] as? String else {
			XCTFail()
			return
		}
		XCTAssertEqual(accessToken, "00Dx0000000BV7z!AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8")
		XCTAssertEqual(refreshToken, "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ==")
		XCTAssertEqual(instanceURL, NSURL(string: "https://na1.salesforce.com")!)
		XCTAssertEqual(identityURL, NSURL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
		
		// Test init with improperly encoded string
		let s = "https://www.salesforce.com?name1=value1#name2=value2"
		XCTAssertNil(Credentials(URLEncodedString: s))
	}
}