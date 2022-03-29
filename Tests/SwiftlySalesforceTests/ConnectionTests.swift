import XCTest
@testable import SwiftlySalesforce

class ConnectionTests: XCTestCase {

    func testThatItHandlesMockRequest() async throws {
        
        // Given
        let data = try load(resource: "MockLimits")
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = Resource.Limits()
        let connection = try Salesforce.connect(session: session)
        
        // When
        let limits: [String: Limit] = try await connection.request(service: service)
        
        // Then
        XCTAssertTrue(limits.count > 0)
    }
}
