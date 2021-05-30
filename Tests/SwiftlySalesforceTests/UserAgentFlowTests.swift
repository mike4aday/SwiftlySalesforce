/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class UserAgentFlowTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }
    
    // Testing user should "Deny" when asked to authorize app
    func testThatItFailsWhenAuthorizationDenied() throws {
     
        debugPrint(">>> Deny authorization when prompted!")
        
        // Given
        let app = try ConnectedApp()
        let provider = app.credentialManager
        let flow = UserAgentFlow(host: provider.defaultHost, consumerKey: provider.consumerKey, callbackURL: provider.callbackURL)
        var error: SalesforceError?
            
        // When
        XCTAssertThrowsError(try waitFor(flow.publisher, timeout: 300)) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error?.code.lowercased(), "access_denied")
    }
    
    func testThatItFailsWithBadAuthURL() throws {
        
        // Given
        let flow = UserAgentFlow(host: "login.salesforce.com", consumerKey: "consumer-key", callbackURL: URL(string: "/path/but/no/scheme")!)
        var error: URLError?
            
        // When
        XCTAssertThrowsError(try waitFor(flow.publisher, timeout: 300)) {
            error = ($0 as? URLError)
        }
        
        // Then
        XCTAssertEqual(error?.code, URLError.badURL)
    }
}
