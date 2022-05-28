import XCTest
@testable import SwiftlySalesforce

class Resource_SObjectsTests: DataServiceTests {

    func testThatItCreatesCreateRecordRequest() throws {
        
        // Given
        let fields = ["Name": "Acme Corp."]
        let service = try Resource.SObjects.Create(type: "Account", fields: fields)
        
        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.post.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url?.path, "/services/data/v\(Resource.defaultVersion)/sobjects/Account")
        XCTAssertEqual(req.httpBody!, try JSONEncoder().encode(fields))
    }
    
    func testThatItHandlesMockCreateRecordResult() async throws {
        
        // Given
        let data = "{\"id\":\"0015d00003TCWCUAA5\",\"success\":true,\"errors\":[]}".data(using: .utf8)!
        let session = URLSession.mock(responseBody: data, statusCode: 201)
        let service = try Resource.SObjects.Create(type: "Account", fields: ["Name": "Acme Corp."])

        // When
        let recordID = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertEqual(recordID, "0015d00003TCWCUAA5")
    }
    
    func testThatItFailsToCreateRecord() async throws {
        
        // Given
        let fields = ["BillingCity": "Austin"]
        let service = try Resource.SObjects.Create(type: "Account", fields: fields)
        
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
        XCTAssertEqual((err as! ResponseError).code, "REQUIRED_FIELD_MISSING")
    }
    
    func testThatItCreatesReadRecordRequest() throws {
        
        // Given
        let service = Resource.SObjects.Read<Record>(type: "Account", id: ":ID", fields: ["Id", "Name", "CustomField__c"])

        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        let comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)!
        let fields: String = comps.queryItems!.first { $0.name == "fields" }!.value!
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.get.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url?.path, "/services/data/v\(Resource.defaultVersion)/sobjects/Account/:ID")
        XCTAssertEqual(fields.filter{ !$0.isWhitespace }, "Id,Name,CustomField__c")
    }
    
    func testThatItReadsMockRecord() async throws {
        
        // Given
        let data = try load(resource: "MockAccount")
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = Resource.SObjects.Read<Record>(type: "", id: "")
        
        // When
        let record = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertNotNil(record.id)
    }
    
    func testThatItHandlesMockFailureToReadRecord() async throws {
        
        // Given
        let data = """
            [{"errorCode":"NOT_FOUND","message":"Provided external ID field does not exist or is not accessible: 123"}]
        """.data(using: .utf8)!
        let session = URLSession.mock(responseBody: data, statusCode: 404)
        let service = Resource.SObjects.Read<Record>(type: "", id: "")
        
        // When
        var err: Error?
        do {
            let _ = try await service.request(with: mockCredential, using: session)
        }
        catch {
            err = error
        }
        
        // Then
        XCTAssertNotNil(err)
        XCTAssertTrue(err is ResponseError)
        XCTAssertEqual((err as! ResponseError).code, "NOT_FOUND")
    }
    
    func testThatItCreatesUpdateRecordRequest() throws {
        
        // Given
        let fields =  ["Name": "Acme Corp."]
        let service = Resource.SObjects.Update(type: "Account", id: ":ID", fields: fields)
        
        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.patch.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url?.path, "/services/data/v\(Resource.defaultVersion)/sobjects/Account/:ID")
        XCTAssertEqual(req.httpBody!, try JSONEncoder().encode(fields))
    }
    
    func testThatItCreatesDeleteRecordRequest() throws {
        
        // Given
        let service = Resource.SObjects.Delete(type: "CustomObject__c", id: ":ID")

        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.delete.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url?.path, "/services/data/v\(Resource.defaultVersion)/sobjects/CustomObject__c/:ID")
    }
    
    func testThatItCreatesUpdatesAndDeletesRecord() async throws {
        
        // Given
        let uuid = UUID().uuidString
        
        // When
        let id = try await XCTestCase.connection.request(service: Resource.SObjects.Create(type: "Account", fields: ["Name": uuid]))
        try await XCTestCase.connection.request(service: Resource.SObjects.Update(type: "Account", id: id, fields: ["BillingCity": uuid]))
        let account = try await XCTestCase.connection.request(service: Resource.SObjects.Read<Record>(type: "Account", id: id))
        try await XCTestCase.connection.request(service: Resource.SObjects.Delete(type: "Account", id: id)) // Remove the just-created record
        let queryResult = try await XCTestCase.connection.request(service: Resource.Query.Run<Record>(soql: "SELECT Id FROM Account WHERE Id = '\(id)'"))
        
        // Then
        XCTAssertEqual(account.string(forField: "BillingCity"), uuid)
        XCTAssertEqual(queryResult.totalSize, 0)
    }
    
    func testThatItCreatesDescribeObjectRequest() async throws {
        
        // Given
        let service = Resource.SObjects.Describe(type: "CustomObject__c")

        // When
        let req = try service.createRequest(with: mockCredential)
        
        // Then
        XCTAssertEqual(req.httpMethod?.uppercased(), HTTP.Method.get.uppercased())
        XCTAssertEqual(req.value(forHTTPHeaderField: "Authorization"), "Bearer \(mockCredential.accessToken)")
        XCTAssertEqual(req.url?.path, "/services/data/v\(Resource.defaultVersion)/sobjects/CustomObject__c/describe")
    }
    
    func testThatItLoadsMockObjectDescribe() async throws {
        
        // Given
        let data = try load(resource: "MockAccountMetadata")
        let session = URLSession.mock(responseBody: data, statusCode: 200)
        let service = Resource.SObjects.Describe(type: "SomeSObject")
        
        // When
        let metadata = try await service.request(with: mockCredential, using: session)
        
        // Then
        XCTAssertEqual(metadata.name, "Account")
    }
    
    func testThatItDescribesAllObjects() async throws {
        
        // Given
        let service = Resource.SObjects.DescribeGlobal()

        // When
        let describes = try await XCTestCase.connection.request(service: service)
        
        // Then
        XCTAssertTrue(describes.count > 0)
        XCTAssertTrue(describes.contains { $0.name == "Account" })
    }
}
