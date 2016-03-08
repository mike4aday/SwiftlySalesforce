//
//  OAuth2ManagerTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 3/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class OAuth2ManagerTests: XCTestCase {

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
	
	func testConfigure() {
	
		// Given
		let consumerKey = "CONSUMER_KEY"
		let callbackURL = NSURL(string: "myprotocol://resource")!
		
		// When
		OAuth2Manager.sharedInstance.configureWithConsumerKey(consumerKey, redirectURL: callbackURL)
		
		// Then
		XCTAssert(OAuth2Manager.sharedInstance.consumerKey == "CONSUMER_KEY")
		XCTAssert(OAuth2Manager.sharedInstance.redirectURL == NSURL(string: "myprotocol://resource")!)
	}
	
	func testStoreCredentials() {
		
		// Given
		let accessToken = "00Dx0000000BB6a!AR8AQBM8J___9kLasZIRyRxZgQcN4HVi43aGcW0qW3JCzf5xdHHHHSoVim8FfJkZE___jaFbberKGk9a9AnYrvChG4qJbBo7" // Not a real access token
		let refreshToken = "5Aep8624iLX.Bq87_!!__PEgaXR9Oo__3JXkX_X4xRxb54_pZ_Xyj1dPEk8ajnw4Kr9ne7VXXVSIQ==" // Not a real refresh token
		let identityURL = NSURL(string: "https://login.salesforce.com/id/00Dx0000000BBBz/005x00000012W1H")!
		let instanceURL = NSURL(string: "https://na1.salesforce.com")!
		let credentials = Credentials(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		
		// When
		do {
			try OAuth2Manager.sharedInstance.storeCredentials(credentials)
		}
		catch {
			XCTFail("\(error)")
		}
		
		// Then
		XCTAssert(credentials == OAuth2Manager.sharedInstance.credentials)
	}
	
	func testClearCredentials() {
		
		// Given
		let accessToken = "00Dx0000000BB6a!AR8AQBM8J___9kLasZIRyRxZgQcN4HVi43aGcW0qW3JCzf5xdHHHHSoVim8FfJkZE___jaFbberKGk9a9AnYrvChG4qJbBo7" // Not a real access token
		let refreshToken = "5Aep8624iLX.Bq87_!!__PEgaXR9Oo__3JXkX_X4xRxb54_pZ_Xyj1dPEk8ajnw4Kr9ne7VXXVSIQ==" // Not a real refresh token
		let identityURL = NSURL(string: "https://login.salesforce.com/id/00Dx0000000BBBz/005x00000012W1H")!
		let instanceURL = NSURL(string: "https://na1.salesforce.com")!
		let credentials = Credentials(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		
		// When
		do {
			try OAuth2Manager.sharedInstance.storeCredentials(credentials)
			try OAuth2Manager.sharedInstance.clearCredentials()
			try OAuth2Manager.sharedInstance.clearCredentials()
		}
		catch {
			XCTFail("\(error)")
		}
		
		// Then
		if let _ = OAuth2Manager.sharedInstance.credentials {
			XCTFail("Credentials not removed")
		}
	}
	
	func testRevokeWithoutToken() {
		
		// Given
		do { try OAuth2Manager.sharedInstance.reset() }
		catch { XCTFail() }
		let expectation = expectationWithDescription("OAuth2 revoke request should fail")
		
		// When
		do { try OAuth2Manager.sharedInstance.clearCredentials() }
		catch { XCTFail() }
		
		// Then
		firstly {
			OAuth2Manager.sharedInstance.revoke()
		}.then {
			() -> () in
			XCTFail()
		}.error {
			(err) -> () in
			if let myError = err as? SwiftlySalesforce.Error {
				if case SwiftlySalesforce.Error.InvalidState = myError {
					expectation.fulfill()
				}
			}
		}
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testRevokeWithBadToken() {
		
		// Given
		do { try OAuth2Manager.sharedInstance.reset() }
		catch { XCTFail() }
		let expectation = expectationWithDescription("OAuth2 revoke request should fail")
		let accessToken = "00Dx0000000BB6a!AR8AQBM8J___9kLasZIRyRxZgQcN4HVi43aGcW0qW3JCzf5xdHHHHSoVim8FfJkZE___jaFbberKGk9a9AnYrvChG4qJbBo7" // Not a real access token
		let refreshToken = "5Aep8624iLX.Bq87_!!__PEgaXR9Oo__3JXkX_X4xRxb54_pZ_Xyj1dPEk8ajnw4Kr9ne7VXXVSIQ==" // Not a real refresh token
		let identityURL = NSURL(string: "https://login.salesforce.com/id/00Dx0000000BBBz/005x00000012W1H")!
		let instanceURL = NSURL(string: "https://na1.salesforce.com")!
		let credentials = Credentials(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken)
		
		// When
		do { try OAuth2Manager.sharedInstance.storeCredentials(credentials) }
		catch { XCTFail() }
		
		// Then
		firstly {
			OAuth2Manager.sharedInstance.revoke()
			}.then {
				() -> () in
				XCTFail()
			}.error {
				(err) -> () in
				if let myError = err as? SwiftlySalesforce.Error {
					if case SwiftlySalesforce.Error.ResponseError = myError {
						expectation.fulfill()
					}
				}
		}
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testAuthenticationCompletedWithFailureResult() {
		
		// Given
		
		// When
		OAuth2Manager.sharedInstance.pendingAuthorization = Promise<Credentials>.pendingPromise()
		let result = AuthenticationResult.Failure(error: SwiftlySalesforce.Error.InvalidState(message: "Something went wrong"))
		OAuth2Manager.sharedInstance.authenticationCompletedWithResult(result)

		// Then
		guard let promise = OAuth2Manager.sharedInstance.pendingAuthorization?.promise else {
			XCTFail()
			return 
		}
		XCTAssert(promise.resolved)
		XCTAssert(promise.rejected)
	}
	
	func testAuthenticationCompletedWithSuccessResult() {
		
		// Given
		
		// When
		OAuth2Manager.sharedInstance.pendingAuthorization = Promise<Credentials>.pendingPromise()
		let creds = Credentials(accessToken: "ACCESS TOKEN", instanceURL: NSURL(string: "http://na1.salesforce.com")!, identityURL: NSURL(string: "https://login.salesforce.com/id/ORGID/USERID")!, refreshToken: "REFRESH TOKEN")
		let result = AuthenticationResult.Success(credentials: creds)
		OAuth2Manager.sharedInstance.authenticationCompletedWithResult(result)
		
		// Then
		guard let promise = OAuth2Manager.sharedInstance.pendingAuthorization?.promise else {
			XCTFail()
			return
		}
		XCTAssert(promise.resolved)
		XCTAssert(promise.fulfilled)
	}
	
	func testRefreshCredentialsWithoutConsumerKey() {
		
		// Tests OAuth2Manager.refreshCredentialsWithToken(refreshToken: String) 
		// without first configuring Consumer Key
		
		// Given
		let expectation = expectationWithDescription("OAuth2 refresh request should fail")
		
		// When
		do {
			try OAuth2Manager.sharedInstance.refreshCredentialsWithToken("REFRESH_TOKEN")
		}
		catch {
			if let err = error as? SwiftlySalesforce.Error {
				if case SwiftlySalesforce.Error.InvalidState = err {
					expectation.fulfill()
				}
			}
		}
		
		// Then
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testRefreshCredentialsWithInvalidToken() {
		
		// Tests OAuth2Manager.refreshCredentialsWithToken(refreshToken: String)
		// with fake refresh token
		
		// Given
		OAuth2Manager.sharedInstance.consumerKey = "CONSUMER_KEY"
		let expectation = expectationWithDescription("OAuth2 refresh request should fail")
		
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
	
	func testAuthorizationURLGetterWithInvalidConfiguration() {
		
		// Given
		OAuth2Manager.sharedInstance.consumerKey = nil
		
		// When
		let authURL = OAuth2Manager.sharedInstance.authorizationURL
		
		// Then
		XCTAssertNil(authURL)
	}
	
	func testAuthorizationURLGetterWithValidConfiguration() {
		
		// Given
		do { try OAuth2Manager.sharedInstance.reset() }
		catch { XCTFail() }
		let redirectURLString = "myprotocol://myresource/after/authorization?name=value&type=something"
		OAuth2Manager.sharedInstance.consumerKey = "CONSUMER_KEY"
		OAuth2Manager.sharedInstance.redirectURL = NSURL(string: redirectURLString)
		
		// When
		guard let authURL = OAuth2Manager.sharedInstance.authorizationURL else {
			XCTFail()
			return
		}
		
		debugPrint(authURL.absoluteString)
		
		// Then
		XCTAssertNotNil(authURL)
		XCTAssertEqual(authURL.valueForQueryItem("response_type"), "token")
		XCTAssertEqual(authURL.valueForQueryItem("client_id"), "CONSUMER_KEY")
		XCTAssertEqual(authURL.valueForQueryItem("redirect_uri"), redirectURLString)
		XCTAssertEqual(authURL.valueForQueryItem("prompt"), "login consent")
		XCTAssertEqual(authURL.valueForQueryItem("display"), "touch")
	}
}
