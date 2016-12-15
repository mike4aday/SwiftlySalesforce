//
//  AuthManagerTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
import Alamofire
@testable import SwiftlySalesforce

class AuthManagerTests: XCTestCase, MockOAuth2Data, LoginDelegate {
	
	var window: UIWindow?
	
	func testThatItRefreshes() {
		
		// GIVEN
		guard let refreshToken = refreshToken, let accessToken = accessToken, let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		let oldAccessToken = accessToken
		debugPrint("Old access token: \(oldAccessToken)")
		let authMgr = AuthManager(configuration: AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self))
		
		// WHEN
		// Revoke the access token
		let exp = expectation(description: "Refresh token")
		let revoke: () -> Promise<Void> = {
			return Promise {
				fulfill, reject in
				Alamofire.request("https://login.salesforce.com/services/oauth2/revoke", method: .get, parameters: ["token": oldAccessToken])
				.validate {
					(request, response, data) -> Request.ValidationResult in
					switch response.statusCode {
					case 200..<300:
						return .success
					case 400:
						// Ignore - could be that acces token is already invalid
						return .success
					default:
						return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
					}
				}
				.responseString { response in
					switch response.result {
					case .success:
						fulfill()
					case .failure(let error):
						reject(error)
					}
				}
			}
		}
		
		// THEN
		revoke().then {
			authMgr.refresh(refreshToken: refreshToken)
		}.then {
			authData -> () in
			debugPrint("New access token: \(authData.accessToken)")
			XCTAssertNotNil(authData.accessToken)
			XCTAssertNotEqual(oldAccessToken, authData.accessToken)
			exp.fulfill()
		}.catch {
			error in
			XCTFail("\(error)")
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItFormsCorrectLoginURL() {
		
		// Given
		guard let consumerKey = consumerKey, let redirectURL = redirectURL else {
			XCTFail()
			return
		}
		let authMgr = AuthManager(configuration: AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self))
		
		// When
		guard let loginURL = try? authMgr.loginURL() else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertNotNil(loginURL)
		XCTAssertEqual(loginURL.value(forQueryItem: "response_type"), "token")
		XCTAssertEqual(loginURL.value(forQueryItem: "client_id"), consumerKey)
		XCTAssertEqual(loginURL.value(forQueryItem: "redirect_uri"), redirectURL.absoluteString)
		XCTAssertEqual(loginURL.value(forQueryItem: "prompt"), "login consent")
		XCTAssertEqual(loginURL.value(forQueryItem: "display"), "touch")
	}
}
