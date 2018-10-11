//
//  RefreshTokenResultTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class RefreshTokenResultTests: XCTestCase {

	let json = """
	{ "id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P", "issued_at":"1278448384422","instance_url":"https://yourInstance.salesforce.com/", "signature":"SSSbLO/gBhmmyNUvN18ODBDFYHzakxOMgqYtu+hDPsc=", "access_token":"00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4","token_type":"Bearer","scope":"id api refresh_token"}
	"""
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testThatItInits() {
		
		let data = json.data(using: .utf8)!
		let decoder = JSONDecoder()
		let result = try! decoder.decode(RefreshTokenResult.self, from: data)
		
		XCTAssertEqual(result.accessToken, "00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4")
		XCTAssertNil(result.communityID)
		XCTAssertNil(result.communityURL)
		XCTAssertEqual(result.identityURL, URL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
		XCTAssertEqual(result.instanceURL, URL(string: "https://yourInstance.salesforce.com/")!)
		XCTAssertEqual(result.issuedAt, 1278448384422)
	}
}
