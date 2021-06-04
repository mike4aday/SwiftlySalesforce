/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class WebAuthenticatorTests: XCTestCase {
        
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testThatItReturnsURL() throws {
        
        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager
        let authURL = URL.userAgentFlow(host: mgr.defaultHost, consumerKey: mgr.consumerKey, callbackURL: mgr.callbackURL)!
        let scheme = mgr.callbackURL.scheme!
        
        // When
        let publisher = WebAuthenticator(authURL: authURL, callbackURLScheme: scheme).publisher
        let augmentedCallbackURL = try waitFor(publisher, timeout: 300)
        
        // Then
        XCTAssertNotNil(augmentedCallbackURL)
    }
}

