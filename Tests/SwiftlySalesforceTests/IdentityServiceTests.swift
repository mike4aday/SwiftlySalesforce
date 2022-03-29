import XCTest
@testable import SwiftlySalesforce

class IdentityServiceTests: DataServiceTests {
    
    func testThatItLoadsMockIdentity() async throws {
        
        // Given
        let data = try load(resource: "MockIdentity")
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = IdentityService()
        
        // When
        let identity = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertNotNil(identity)
    }
    
    func testThatItRequiresAuthentication() async throws {
        
        // Given
        let responseBody = """
            [{"message": "Something went wrong!", "errorCode": "SOMETHING_WENT_WRONG"}]
        """
        let session = URLSession.mock(responseBody: responseBody.data(using: .utf8)!, statusCode: 403)
        let service = IdentityService()

        // When
        var err: Error? = nil
        do {
            let _ = try await service.request(with: mockCredential, using: session)
        }
        catch let error {
            err = error
        }
        
        // Then
        XCTAssertNotNil(err)
        XCTAssertTrue(err!.isAuthenticationRequired)
    }
    
    func testThatItHandlesMockResponseError() async throws {
        
        // Given
        let responseBody = """
            [{"message": "Something went wrong!", "errorCode": "SOMETHING_WENT_WRONG"}]
        """
        let session = URLSession.mock(responseBody: responseBody.data(using: .utf8)!, statusCode: 414)
        let service = IdentityService()

        // When
        var err: Error? = nil
        do {
            let _ = try await service.request(with: mockCredential, using: session)
        }
        catch {
            err = error
        }
        
        // Then
        XCTAssertNotNil(err)
        XCTAssertTrue(err is ResponseError)
        XCTAssertEqual((err as! ResponseError).code, "SOMETHING_WENT_WRONG")
        XCTAssertEqual((err as! ResponseError).message, "Something went wrong!")
        XCTAssertEqual((err as! ResponseError).metadata.statusCode, 414)
    }
    
    func testThatItFailsToDecodeMockIdentity() async throws {
        
        // Given
        let responseBody = """
            {"message": "I am not an Identity JSON structure", "errorCode": "SOMETHING_WENT_WRONG"}
        """
        let session = URLSession.mock(responseBody: responseBody.data(using: .utf8)!, statusCode: 201)
        let service = IdentityService()

        // When
        var err: Error? = nil
        do {
            let _ = try await service.request(with: mockCredential, using: session)
        }
        catch {
            err = error
        }
        
        // Then
        XCTAssertNotNil(err)
        XCTAssertTrue(err is DecodingError)
    }
}
