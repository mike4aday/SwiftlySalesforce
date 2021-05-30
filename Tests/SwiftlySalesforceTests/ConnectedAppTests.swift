/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce9

class ConnectedAppTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testThatItLogsIn() throws {
        
        // Given
        let app = try ConnectedApp()
        
        // When
        let cred = try waitFor(app.logIn(), timeout: 300)
        
        // Then
        XCTAssertNotNil(cred)
    }
    
    func testThatItLogsOut() throws {
        
        // Given
        let app = try ConnectedApp()
        let cred = try waitFor(app.getCredential(allowsLogin: true), timeout: 300)
        
        // When
        let _ = try waitFor(app.logOut(user: cred.user))
        
        // Then
        XCTAssertNil(try app.credentialManager.getStoredCredential(for: cred.user))
    }
    
    func testThatItFailsWithoutCredential() throws {
        
        // Given
        let app = try ConnectedApp()

        // When
        var error: SalesforceError?
        let cred = try waitFor(app.getCredential(), timeout: 300)
        try waitFor(app.logOut(user: cred.user), timeout: 300)
        XCTAssertThrowsError(try waitFor(app.identity(allowsLogin: false), timeout: 300)) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error, SalesforceError.userAuthenticationRequired)
    }
    
    func testThatItInitializesFromJSONConfig() throws {
        
        // Given
        let consumerKey = "consumer-key"
        let callbackURL = URL(string: "/callback/url")!
        let host = "test.salesforce.com"
        let config = Configuration(consumerKey: consumerKey, callbackURL: callbackURL, defaultAuthHost: host)
        
        // When
        let app = ConnectedApp(configuration: config)
        
        // Then
        XCTAssertEqual(app.credentialManager.consumerKey, consumerKey)
        XCTAssertEqual(app.credentialManager.callbackURL, callbackURL)
        XCTAssertEqual(app.credentialManager.defaultHost, host)
    }
    
    func testThatItGetsCredential() throws {
        
        // Given
        let app = try ConnectedApp()

        // When
        let cred = try waitFor(app.getCredential(), timeout: 300)
        
        // Then
        XCTAssertNotNil(cred)
    }
}
