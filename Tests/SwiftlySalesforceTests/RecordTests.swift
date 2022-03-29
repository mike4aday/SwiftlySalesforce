import XCTest
@testable import SwiftlySalesforce

class RecordTests: XCTestCase {
    
    let decoder = JSONDecoder(dateFormatter: .salesforce(.long))

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testThatItInitializesWithJSONData() throws {
        
        // Given
        let data = try load(resource: "MockAccount")
        
        // When
        let record = try decoder.decode(Record.self, from: data)
        
        // Then
        XCTAssertEqual(record.id, "0011Y00003HVMu4QAH")
        XCTAssertEqual(record.type, "Account")
        XCTAssertFalse(record["IsDeleted"]! as Bool)
        XCTAssertTrue(record["namespace2__Is_Covered__c"]! as Bool)
        XCTAssertEqual(record["BillingState"]! as String, "AK")
        XCTAssert(record["BillingLatitude"]! as Double == 61.217061)
        let billingAddress: Address = record["BillingAddress"]!
        XCTAssert(billingAddress.state == "AK")
        XCTAssert(billingAddress.latitude == 61.217061)
        XCTAssert(record["ParentId"] as String? == nil)
        XCTAssert(record["Type"] as String? != nil)
        let lastModDate: Date = record["LastModifiedDate"]!
        let components = Calendar(identifier: .gregorian).dateComponents([.minute], from: lastModDate)
        XCTAssert(components.minute == 33)
    }
    
    func testThatItInitializesWithAggregateQueryResult() throws {
        
        // Given
        let data = try load(resource: "MockAggregateQueryResult")
        
        // When
        let result = try decoder.decode(QueryResult<Record>.self, from: data)
        
        // Then
        XCTAssertTrue(result.records.count > 0)
        for record in result.records {
            XCTAssertEqual(record.type, "AggregateResult")
            XCTAssertEqual(record.id, "")
        }
    }
    
    func testThatItFailsToInitializeWithBadRecordJSON() throws {
        
        // Given
        let data = try load(resource: "MockAccountMissingURLAttribute")
        
        // When
        let result = try? decoder.decode(Record.self, from: data)
        
        // Then
        XCTAssertNil(result)
    }
    
    func testThatHelperMethodsWork() throws {
        
        // Given
        let data = try load(resource: "MockAccount")

        // When
        let record = try decoder.decode(Record.self, from: data)
        
        // Then
        XCTAssertTrue(record.hasField(named: "Name"))
        XCTAssertFalse(record.hasField(named: UUID().uuidString))
        XCTAssertNotNil(record.double(forField: "BillingLatitude"))
        XCTAssertNil(record.string(forField: "BillingLatitude"))
        XCTAssertNotNil(record.string(forField: "Website"))
        XCTAssertNotNil(record.url(forField: "Website"))
        XCTAssertNotNil(record.date(forField: "CreatedDate"))
        XCTAssertNil(record.int(forField: "CreatedDate"))
        XCTAssertNil(record.date(forField: "LastActivityDate"))
        XCTAssertNotNil(record.address(forField: "BillingAddress"))
        XCTAssert(record.address(forField: "BillingAddress")!.city == "Anchorage")
        XCTAssertNotNil(record.float(forField: "BillingLatitude"))
        XCTAssertNil(record.float(forField: "BillingCity"))
        XCTAssertTrue(record.bool(forField: "namespace2__Is_Covered__c")!)
    }
}
