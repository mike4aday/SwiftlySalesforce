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
	
	let redirectURLString = """
	https://www.mysite.com/user_callback.jsp#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https%3A%2F%2FyourInstance.salesforce.com&id=https%3A%2F%2Flogin.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate
	"""
	
	let redirectURLStringWithIDToken = """
	test://callback#access_token=00D0t1000007wx9EWW%21AQkAQMZWOwYvWheC9Py61r8mTlYcg7pILWtN9Ob6tPuXN3rjAull5SjzJITSXn7CSwvyc5Tx1BWkjTFzhzJa70S3gwds3uCI&instance_url=https%3A%2F%2Ftesting--DEV2.cs73.my.salesforce.com&id=https%3A%2F%2Ftest.salesforce.com%2Fid%2F00D0t1000007wx9EWW%2F0050t000001KNflAAG&issued_at=1449038298918&signature=w0wIxwwVD1UWB4eEjmxMjE3faFp9zxqnj6WXnbqV5Ak%3D&sfdc_community_url=https%3A%2F%2Fdev2-testing.cs77.force.com&sfdc_community_id=0DB1I0000003WbKWWW&id_token=kwWraWWiOwIyWWWiLCJ0eXAwOwJKV1QwLCJhbGciOiJSUwI1NiJ9.tyJhdF9oYXNoIjoiSHROblRtcHQwRlhJWVgwN3E2UzlWUSIsInN1YiI6Imh0dWBzOi8vdGVzdC5zYWxlc2XvcmNlXmNvbS9pZC8wMEQwdDAwMDAwMDhmwDlFQUEwMDA1MHQwMDAwMDFLTmZwQUFHIiwiYXVkIjoiM01WRzlpZw1BS0NISVNiYVR6Q3JuQWx3SVwmTERNNGV2UUxmcTZDVkpIVnd2ZzdrOHR3VGVReHJzYWszMGhERHo0VHppNzFncC56bUZLbXVfRWxnciIsImlzcyI6Imh0dHBzOi8vcWEyLXBoaWxhbnRocm9weWNsb3VkLmNzNzcuZm9yY2UuY29tIiwiZXhwIjoxNTM5MDM4NDE4LCJpYXQiOjE1MzkwMzgyOTgsIm5vbmNlIjmiKG5vbmNlKSIsImN1c3RvbV9hdHRyaWJ1dGVzIjp7IlVzZXJuYW1lIjoidGVzdGVtcGxvwWV
	"""
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testThatItInitsWithRedirectURL() {
		
		let url = URL(string: redirectURLString)!
		let auth = try! Authorization(with: url)
		
		XCTAssertEqual(auth.accessToken, "00Dx0000000BV7z!AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8")
		XCTAssertEqual(auth.refreshToken, "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ==")
		XCTAssertEqual(auth.instanceURL, URL(string: "https://yourInstance.salesforce.com")!)
		XCTAssertEqual(auth.identityURL, URL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
		XCTAssertEqual(auth.orgID, "00Dx0000000BV7z")
		XCTAssertEqual(auth.userID, "005x00000012Q9P")
	}
	
	func testThatItInitsWithRedirectURLAndIDTokenAndCommunityInfo() {
		
		let url = URL(string: redirectURLStringWithIDToken)!
		let auth = try! Authorization(with: url)
		
		XCTAssertEqual(auth.accessToken, "00D0t1000007wx9EWW!AQkAQMZWOwYvWheC9Py61r8mTlYcg7pILWtN9Ob6tPuXN3rjAull5SjzJITSXn7CSwvyc5Tx1BWkjTFzhzJa70S3gwds3uCI")
		XCTAssertNil(auth.refreshToken)
		XCTAssertEqual(auth.instanceURL, URL(string: "https://testing--DEV2.cs73.my.salesforce.com")!)
		XCTAssertEqual(auth.identityURL, URL(string: "https://test.salesforce.com/id/00D0t1000007wx9EWW/0050t000001KNflAAG")!)
		XCTAssertEqual(auth.orgID, "00D0t1000007wx9EWW")
		XCTAssertEqual(auth.userID, "0050t000001KNflAAG")
		XCTAssertEqual(auth.idToken, "kwWraWWiOwIyWWWiLCJ0eXAwOwJKV1QwLCJhbGciOiJSUwI1NiJ9.tyJhdF9oYXNoIjoiSHROblRtcHQwRlhJWVgwN3E2UzlWUSIsInN1YiI6Imh0dWBzOi8vdGVzdC5zYWxlc2XvcmNlXmNvbS9pZC8wMEQwdDAwMDAwMDhmwDlFQUEwMDA1MHQwMDAwMDFLTmZwQUFHIiwiYXVkIjoiM01WRzlpZw1BS0NISVNiYVR6Q3JuQWx3SVwmTERNNGV2UUxmcTZDVkpIVnd2ZzdrOHR3VGVReHJzYWszMGhERHo0VHppNzFncC56bUZLbXVfRWxnciIsImlzcyI6Imh0dHBzOi8vcWEyLXBoaWxhbnRocm9weWNsb3VkLmNzNzcuZm9yY2UuY29tIiwiZXhwIjoxNTM5MDM4NDE4LCJpYXQiOjE1MzkwMzgyOTgsIm5vbmNlIjmiKG5vbmNlKSIsImN1c3RvbV9hdHRyaWJ1dGVzIjp7IlVzZXJuYW1lIjoidGVzdGVtcGxvwWV")
		XCTAssertEqual(auth.communityURL, URL(string: "https://dev2-testing.cs77.force.com")!)
		XCTAssertEqual(auth.communityID, "0DB1I0000003WbKWWW")
	}
	
	func testThatItDoesntInitWithInvalidURL() {
		
		let urlString = "https://www.mysite.com/noparameters#"
		let url = URL(string: urlString)!
		let auth = try? Authorization(with: url)
		
		XCTAssertNil(auth)
	}
	
	func testThatItRefreshes() {
		
		let auth1 = Authorization(
			accessToken: "ACCESS_TOKEN",
			instanceURL: URL(string: "https://na1.salesforce.com")!,
			identityURL: URL(string: "https://test.salesforce.com/id/00D0t1000007wx9EWW/0050t000001KNflAAG")!,
			refreshToken: "REFRESH_TOKEN", issuedAt: 123456789, idToken: nil, communityURL: nil, communityID: nil)
		
		let refresh = RefreshTokenResult(
			accessToken: "ACCESS_TOKEN_2",
			instanceURL: URL(string: "https://na2.salesforce.com")!,
			identityURL: URL(string: "https://test2.salesforce.com/id/00D0t1000007wx9EWW/0050t000001KNflAAG")!,
			issuedAt: 123456790,
			communityURL: URL(string: "https://dev2-testing.cs77.force.com")!,
			communityID: "0DB1I0000003WbKWWW")
		
		let auth2 = auth1.refreshedWith(result: refresh)
		
		XCTAssertEqual(auth2.accessToken, refresh.accessToken)
		XCTAssertEqual(auth2.communityID, refresh.communityID)
		XCTAssertEqual(auth2.communityURL, refresh.communityURL)
		XCTAssertEqual(auth2.identityURL, refresh.identityURL)
		XCTAssertEqual(auth2.idToken, auth1.idToken)
		XCTAssertEqual(auth2.instanceURL, refresh.instanceURL)
		XCTAssertEqual(auth2.issuedAt, refresh.issuedAt)
		XCTAssertEqual(auth2.refreshToken, auth1.refreshToken)
	}
}
