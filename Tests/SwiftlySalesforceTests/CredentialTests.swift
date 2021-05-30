/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class CredentialTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }
    
    func testThatItInitializesWithCallbackURL() throws {
        
        // Given
        let callback = "myapp://callback#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https://yourInstance.salesforce.com&id=https://login.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate"
        let callbackURL = URL(string: callback)!
        
        // When
        let cred = Credential(fromURLEncodedString: callbackURL.fragment!)!
        
        // Then
        XCTAssertEqual(cred.accessToken, "00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8".removingPercentEncoding)
        XCTAssertEqual(cred.refreshToken, "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D".removingPercentEncoding)
        XCTAssertEqual(cred.instanceURL, URL(string: "https://yourInstance.salesforce.com")!)
        XCTAssertEqual(cred.identityURL, URL(string: "https://login.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P".removingPercentEncoding)!)
        XCTAssertNil(cred.siteID)
        XCTAssertNil(cred.siteURL)
        XCTAssertEqual(cred.timestamp, Date(timeIntervalSince1970: 1278448101.416))
    }
}
