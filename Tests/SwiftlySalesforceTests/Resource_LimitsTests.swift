import XCTest
@testable import SwiftlySalesforce

class Resource_LimitsTests: DataServiceTests {
    
    func testThatItCreatesURLRequest() throws {
        
        // Given
        let service = Resource.Limits()

        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.get.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url?.path, "/services/data/v\(Resource.defaultVersion)/limits")
    }
    
    func testThatItLoadsMockLimits() async throws {
        
        // Given
        let data = try load(resource: "MockLimits")
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = Resource.Limits()
        
        // When
        let limits = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertTrue(limits.count > 0)
        XCTAssertTrue(limits["DailyApiRequests"]!.remaining >= 0)
    }
}
