/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import XCTest
@testable import SwiftlySalesforce

class IdentityTests: XCTestCase {
 
    func testThatItDecodesIdentity() throws {
        
        // Given
        let decoder = JSONDecoder(dateDecodingStrategy: .iso8601)
        let data = MockIdentityResponse.json.data(using: .utf8)!
        
        // When
        let identity = try! decoder.decode(Identity.self, from: data)
        
        // Then
        XCTAssertEqual(identity.userID, "005i00000018PdaAEE")
        XCTAssertEqual(identity.orgID, "00Di0000000bcJ3EEI")
        XCTAssertEqual(identity.username, "mvannostrand@vandelayind.com")
        XCTAssertEqual(identity.displayName, "Martin Van Nostrand")
        XCTAssertNil(identity.zip)
        XCTAssertNil(identity.mobilePhone)
        XCTAssertEqual(identity.timezone, "America/Los_Angeles")
    }
}

