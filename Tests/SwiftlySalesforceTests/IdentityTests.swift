import XCTest
@testable import SwiftlySalesforce

class IdentityTests: XCTestCase {

    func testThatItInitializes() throws {
        
        // Given
        let data = try load(resource: "MockIdentity", withExtension: "json")
        let decoder = JSONDecoder(dateDecodingStrategy: .iso8601)
        
        // When
        let identity = try decoder.decode(Identity.self, from: data)
        
        // Then
        XCTAssertNotNil(identity)
        XCTAssertEqual(identity.username, "john@playground.com")
        XCTAssertEqual(identity.state, "CA")
        XCTAssertNil(identity.mobilePhone)
    }
}
