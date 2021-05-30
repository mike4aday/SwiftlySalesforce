/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce9

class ConnectedApp_Limits_Tests: XCTestCase {
    
    func testThatItLoadsLimits() throws {
        
        // Given
        let app = try ConnectedApp()
        
        // When
        let limits = try waitFor(app.limits(), timeout: 300)
        
        // Then
        XCTAssert(limits.count > 0)
        for (name, limit) in limits {
            // As long as we have limits here, test Limit struct, too...
            XCTAssertNotNil(name)
            XCTAssert(limit.used + limit.remaining == limit.maximum)
        }
    }
}
