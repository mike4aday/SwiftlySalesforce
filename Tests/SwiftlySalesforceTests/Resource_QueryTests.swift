import XCTest
@testable import SwiftlySalesforce

class Resource_QueryTests: XCTestCase {

    func testThatItLoadsMockAggregateQueryResults() async throws {
    
        // Given
        let data = try load(resource: "MockAggregateQueryResult")
        let soql = "<SOME SOQL HERE>"
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = Resource.Query.Run<Record>(soql: soql)
        
        // When
        let queryResults = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertTrue(queryResults.records.count > 0)
        for record in queryResults.records {
            XCTAssertEqual(record.type, "AggregateResult")
            XCTAssertTrue(record.int(forField: "MyCount")! >= 0)
        }
    }
    
    func testThatItQueries() async throws {
        
        // Given
        let soql = "SELECT ActivityDate, Status, Count(Id) MyCount FROM Task WHERE CreatedDate > 2011-04-26T10:00:00+01:00 GROUP BY ActivityDate, Status"
        let service = Resource.Query.Run<Record>(soql: soql)
        
        // When
        let queryResults = try await XCTestCase.connection.request(service: service)
        
        // Then
        for record in queryResults.records {
            XCTAssertEqual(record.type, "AggregateResult")
            XCTAssertEqual(record.id, "")
        }
    }
    
    func testThatItHandlesResponseError() async throws {
        
        // Given
        let soql = "SELECT FieldThatDoesNotExist FROM Account"
        let service = Resource.Query.Run<Record>(soql: soql)
        var err: Error? = nil
        
        // When
        do {
            let _ = try await XCTestCase.connection.request(service: service)
        }
        catch {
            err = error
        }
        
        // Then
        XCTAssertNotNil(err)
        XCTAssertTrue(err is ResponseError)
    }
    
    func testThatItCreatesRequestForMyAccountsWithLimit() async throws {
        
        // Given
        let service = Resource.Query.MyRecords<Record>(type: "SomeObject", batchSize: 203)
        
        // When
        let req = try service.createRequest(with: mockCredential)
        let comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)!
        let soql: String = comps.queryItems!.first { $0.name == "q" }!.value!
        
        // Then
        XCTAssertTrue(soql.hasSuffix("LIMIT 200"))
        XCTAssertTrue(soql.contains("FIELDS(ALL)"))
        XCTAssertTrue(soql.filter{ !$0.isWhitespace }.contains("OwnerId='\(mockCredential.userID)'"))
        XCTAssertEqual(req.value(forHTTPHeaderField: "Sforce-Query-Options"), "batchSize=203")
    }
    
    func testThatItCreatesRequestForMyAccountsWithoutLimit() async throws {
        
        // Given
        let service = Resource.Query.MyRecords<Record>(type: "SomeObject", fields: ["Name","LastModifiedDate"])
        
        // When
        let req = try service.createRequest(with: mockCredential)
        let comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)!
        let soql: String = comps.queryItems!.first { $0.name == "q" }!.value!
        
        // Then
        XCTAssertFalse(soql.hasSuffix("LIMIT 200"))
        XCTAssertFalse(soql.contains("FIELDS(ALL)"))
        XCTAssertTrue(soql.contains("SELECT Name,LastModifiedDate FROM SomeObject"))
        XCTAssertTrue(soql.filter{ !$0.isWhitespace }.contains("OwnerId='\(mockCredential.userID)'"))
    }
    
    func testThatItQueriesMyAccounts() async throws {
        
        // Given
        struct MyAccount: Decodable {
            var Id: String
            var Name: String
            var LastModifiedDate: Date
            var OwnerId: String
            var BillingCountry: String?
        }
        let service = Resource.Query.MyRecords<MyAccount>(type: "Account", fields: ["Id", "Name", "LastModifiedDate", "OwnerId", "BillingCountry"], batchSize: 203)
        
        // When
        let queryResults = try await XCTestCase.connection.request(service: service)
        
        // Then
        XCTAssertTrue(queryResults.records.dropLast().allSatisfy { $0.OwnerId == queryResults.records.last?.OwnerId })
    }
    
    func testThatItQueriesNextPageIfAvailable() async throws {
        
        // Given
        let soql = "SELECT Id,Name FROM Account"
        let service = Resource.Query.Run<Record>(soql: soql, batchSize: 203)
        
        // When
        if let path = try await XCTestCase.connection.request(service: service).nextRecordsPath {
            let nextPage = try await XCTestCase.connection.request(service: Resource.Query.NextResultsPage<Record>(path: path, batchSize: 204))
            XCTAssertTrue(nextPage.isDone == (nextPage.nextRecordsPath == nil))
        }
        
        // Then
        // Done
    }
}
