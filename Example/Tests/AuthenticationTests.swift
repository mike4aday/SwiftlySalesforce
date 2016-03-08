//
//  AuthenticationTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 3/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftlySalesforce
import PromiseKit


class AuthenticationTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		do { try OAuth2Manager.sharedInstance.reset() }
		catch { XCTFail() }
	}
	
	override func tearDown() {
		super.tearDown()
		do { try OAuth2Manager.sharedInstance.reset() }
		catch { XCTFail() }
	}
	
	func testResultFromRedirectURLSuccess() {
		
		// Given
		let redirectURL = NSURL(string: "https://www.mysite.com/user_callback.jsp#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https%3A%2F%2Fna1.salesforce.com&id=https%3A%2F%2Flogin.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate")!
		
		let tester = Tester()
		
		// When
		guard let result = try? tester.resultFromRedirectURL(redirectURL) else {
			XCTFail()
			return
		}
		
		// Then
		switch result {
		case let .Success(credentials):
			XCTAssertEqual(credentials.accessToken, "00Dx0000000BV7z!AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8")
		case .Failure:
			XCTFail()
		}
	}

	func testResultFromRedirectURLFailure() {
		
		// Given
		let redirectURL = NSURL(string: "myprotocol://resource#error=access_denied&error_description=the%20user%20denied%20authorization&state=mystate")!
		let tester = Tester()
		
		// When
		guard let result = try? tester.resultFromRedirectURL(redirectURL) else {
			XCTFail()
			return
		}
		
		// Then
		switch result {
		case .Success:
			return
		case .Failure(let err):
			if let myError = err as? SwiftlySalesforce.Error {
				if case .ResponseError = myError {
					// Continue
				}
				else {
					XCTFail()
				}
			}
			else {
				XCTFail()
			}
		}
	}
	
	func testResultFromRedirectURLWithInvalidURL() {
		
		// Given
		let redirectURL1 = NSURL(string: "myprotocol://resource")!
		let redirectURL2 = NSURL(string: "myprotocol://resource#errorXXXX=access_denied&error_descriptionXXXX=the%20user%20denied%20authorization&state=mystate")!
		let tester = Tester()

		// When

		// Then
		XCTAssertNil(try? tester.resultFromRedirectURL(redirectURL1))
		XCTAssertNil(try? tester.resultFromRedirectURL(redirectURL2))
	}
	
	func testRefreshCredentialsWithToken() {
		
		// Given
		do { try OAuth2Manager.sharedInstance.reset() }
		catch { XCTFail() }
		OAuth2Manager.sharedInstance.consumerKey = "CONSUMER_KEY"
		let expectation = expectationWithDescription("Refresh should fail")
		
		// When
		do {
			try OAuth2Manager.sharedInstance.refreshCredentialsWithToken("REFRESH_TOKEN").then {
				(credentials) -> () in
				XCTFail("Should not have succeeded")
				}.error {
					(error) -> () in
					if let err = error as? SwiftlySalesforce.Error {
						if case SwiftlySalesforce.Error.ResponseError = err {
							expectation.fulfill()
						}
					}
					else {
						XCTFail("Failed, but not as expected")
					}
			}
		}
		catch {
			XCTFail("\(error)")
		}
		
		// Then
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testLogOut() {
		
		// Given
		OAuth2Manager.sharedInstance.consumerKey = "CONSUMER_KEY"
		let tester = Tester()
		let expectation = expectationWithDescription("Log out should fail")
		
		// When
		tester.logOut().then {
			() -> () in
			// Shouldn't get here
			XCTFail()
			return
		}.error {
			(error) -> Void in
			if let err = error as? SwiftlySalesforce.Error {
				if case SwiftlySalesforce.Error.InvalidState = err {
					expectation.fulfill()
				}
			}
			else {
				XCTFail()
			}
		}
		
		// Then
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testLoggingInGetter() {
		
		// Given
		OAuth2Manager.sharedInstance.consumerKey = "CONSUMER_KEY"
		let tester = Tester()
		
		// When
		let loggingIn = tester.loggingIn
		
		// Then
		XCTAssert(!loggingIn)
	}
	
	func testAuthenticateWithURL() {
		
		// Given
		OAuth2Manager.sharedInstance.consumerKey = "CONSUMER_KEY"
		OAuth2Manager.sharedInstance.redirectURL = NSURL(string: "myRedirectURI://authenticated")!
		let tester = Tester()
		
		// When
		do {
			try tester.startLoginWithURL(OAuth2Manager.sharedInstance.authorizationURL!)
		}
		catch {
			XCTFail()
		}
	}
}


final class Tester: NSObject, UIApplicationDelegate, LoginViewPresentable {
	
	var window: UIWindow? = nil
	
	func startLoginWithURL(loginURL: NSURL) throws {
		//TDOO:
	}
}
