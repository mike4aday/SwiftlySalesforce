/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce9

class RecordTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }
    
    func testThatItInitializesWithJSONData() throws {
        
        // Given
        let data = MockAccountResponse(id: "0011Y00003HVMu4QAH").json.data(using: .utf8)!
        
        // When
        let record = try JSONDecoder.salesforce.decode(Record.self, from: data)
        
        // Then
        XCTAssertEqual(record.id, "0011Y00003HVMu4QAH")
        XCTAssertEqual(record.type, "Account")
        XCTAssertFalse(record["IsDeleted"]! as Bool)
        XCTAssertTrue(record["namespace2__Is_Covered__c"]! as Bool)
        XCTAssertEqual(record["BillingState"]! as String, "AK")
        XCTAssert(record["BillingLatitude"]! as Double == 61.217061)
        guard let billingAddress: Address = record["BillingAddress"] else {
            return XCTFail()
        }
        XCTAssert(billingAddress.state == "AK")
        XCTAssert(billingAddress.latitude == 61.217061)
        XCTAssert(record["ParentId"] as String? == nil)
        XCTAssert(record["Type"] as String? != nil)
        guard let lastModDate: Date = record["LastModifiedDate"] else {
            return XCTFail()
        }
        let components = Calendar(identifier: .gregorian).dateComponents([.minute], from: lastModDate)
        XCTAssert(components.minute == 33)
    }
    
    func testThatHelperMethodsWork() throws {
        
        // Given
        let data = MockAccountResponse(id: "0011Y00003HVMu4QAH").json.data(using: .utf8)!
        
        // When
        let record = try JSONDecoder.salesforce.decode(Record.self, from: data)
        
        // Then
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
    }
}
