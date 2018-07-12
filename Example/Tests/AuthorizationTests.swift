//
//  AuthorizationTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class AuthorizationTests: XCTestCase {
	
	let urlString = """
	https://www.mysite.com/user_callback.jsp#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https%3A%2F%2FyourInstance.salesforce.com&id=https%3A%2F%2Flogin.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate
	"""
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testThatItInitsWithURL() {
		
		let url = URL(string: urlString)!
		let auth = try! Authorization(with: url)
		
		XCTAssertEqual(auth.accessToken, "00Dx0000000BV7z!AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8")
		XCTAssertEqual(auth.refreshToken, "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ==")
		XCTAssertEqual(auth.instanceURL, URL(string: "https://yourInstance.salesforce.com")!)
		XCTAssertEqual(auth.identityURL, URL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
		XCTAssertEqual(auth.orgID, "00Dx0000000BV7z")
		XCTAssertEqual(auth.userID, "005x00000012Q9P")
	}
	
	func testThatItDoesntInitWithInvalidURL() {
		
		let urlString = "https://www.mysite.com/noparameters#"
		let url = URL(string: urlString)!
		let auth = try? Authorization(with: url)
		
		XCTAssertNil(auth)
	}
}
