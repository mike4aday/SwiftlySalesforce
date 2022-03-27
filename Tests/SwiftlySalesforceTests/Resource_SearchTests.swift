import XCTest
@testable import SwiftlySalesforce

class Resource_SearchTests: DataServiceTests {

    func testThatItLoadsMockSearchResults() async throws {
        
        // Given
        let data = try load(resource: "MockSearchResults")
        let sosl = "<SOME SOSL HERE>"
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = Resource.Search(sosl: sosl)
        
        // When
        let searchResults = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertTrue(searchResults.count > 0)
        XCTAssertEqual(searchResults.first!.type, "Contact")
        XCTAssertEqual(searchResults[searchResults.count - 2].int(forField: "NumberOfEmployees"), 1000)
    }
    
    func testThatItSearches() async throws {
        
        // Given
        let sosl = "FIND {*ac*} IN Name FIELDS RETURNING Account(Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, LastActivityDate), Contact(Id, Name, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry), Opportunity(Id, Name, ExpectedRevenue)"
        let service = Resource.Search(sosl: sosl)
        
        // When
        let searchResults = try await XCTestCase.connection.request(service: service)
        
        // Then
        XCTAssertNotNil(searchResults)
    }
    
    func testThatItHandlesSyntaxError() async throws {
        
        // Given
        let sosl = "FIND %ac% IN Name FIELDS RETURNING Account(Id, Name)" // Badly formed SOSL string
        let service = Resource.Search(sosl: sosl)
        
        // When
        var err: Error?
        do {
            let _ = try await XCTestCase.connection.request(service: service)
        }
        catch {
            err = error
        }
        
        // Then
        XCTAssertNotNil(err)
        XCTAssertTrue(err is ResponseError)
        XCTAssertTrue((400..<500).contains((err as! ResponseError).metadata.statusCode))
    }
}
