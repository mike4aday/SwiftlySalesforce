/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class ConnectApp_Identity_Tests: XCTestCase {
    
    func testThatItLoadsIdentity() throws {
        
        // Given
        let app = try ConnectedApp()
        
        // When
        let identity = try waitFor(app.identity(), timeout: 300)
        
        // Then
        print(identity)
    }
}
