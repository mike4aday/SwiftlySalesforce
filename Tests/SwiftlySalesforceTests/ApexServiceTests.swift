import XCTest
@testable import SwiftlySalesforce

class ApexServiceTests: DataServiceTests {
    
    func testsThatItCreatesRequestForApexRestService() throws {
        
        // Given
        let body = "Hello, World!"
        let service = ApexService<Record>(path: "Account/:ID", method: "PATCH", queryItems: nil, headers: ["Header1": "Value1"], body: body.data(using: .utf8), timeoutInterval: 12345)
        
        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.patch.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url!.path, "/services/apexrest/Account/:ID")
        XCTAssertEqual(req.httpBody!, body.data(using: .utf8))
    }
}
