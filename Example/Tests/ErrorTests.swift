//
//  ErrorTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 3/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import SwiftlySalesforce

class ErrorTests: XCTestCase {

    func testErrorCases() {
	
		// Given
		let invalidStateError = Error.InvalidState(message: "Hi from an invalid state")
		let invalidArgumentError = Error.InvalidArgument(message: "Hi from an invalid argument")
		let authenticationFailureError = Error.AuthenticationFailure(message: "Hi from an authentication failure")
		let responseError = Error.ResponseError(code: "access_denied", description: "the+user+denied+authorization")
		
		// When
		
		// Then
		XCTAssertEqual(invalidStateError.description, "Hi from an invalid state")
		XCTAssertEqual(invalidArgumentError.description, "Hi from an invalid argument")
		XCTAssertEqual(authenticationFailureError.description, "Hi from an authentication failure")
		XCTAssertEqual(responseError.description, "Access denied: the user denied authorization")
	}

	func testResponseErrorFromURLEncodedString() {
		
		// Given
		let redirectURL = "https://www.mysite.com/user_callback.jsp#error=access_denied&error_description=the%20user%20denied%20authorization&state=mystate"
		
		// When
		guard let fragment = NSURL(string: redirectURL)?.fragment, error = Error.errorFromURLEncodedString(fragment) else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertEqual(error.description, "Access denied: the user denied authorization")
	}
	
	func testResponseErrorFromInvalidURLEncodedString() {
		
		// Given
		let redirectURL = "https://www.mysite.com/user_callback.jsp#errorXXX=access_denied&error_description=the%20user%20denied%20authorization&state=mystate"
		
		// When
		guard let fragment = NSURL(string: redirectURL)?.fragment else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertNil(Error.errorFromURLEncodedString(fragment))
	}
}
