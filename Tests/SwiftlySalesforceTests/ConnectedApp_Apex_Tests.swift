/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce9

class ConnectedApp_Apex_Tests: XCTestCase {
    
    // This test assumes there is an Apex REST service mapped to /RandomAccount in namespace "playgroundorg"
    // and at least 1 accessible Account record
    func testThatItLoadsCustomApexRESTService() throws {
        
        // Given
        let app = try ConnectedApp()
        
        // When
        let pub: AnyPublisher<SalesforceRecord, Error> = app.apex(namespace: "playgroundorg", relativePath: "RandomAccount")
        let randomAccount: SalesforceRecord = try waitFor(pub, timeout: 300)
        
        // Then
        XCTAssertNotNil(randomAccount.string(forField:"Name"))
    }
}
