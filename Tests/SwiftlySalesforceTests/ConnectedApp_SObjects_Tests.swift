/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce9

class ConnectApp_SObjects_Tests: XCTestCase {
    
    func testThatItRetrievesMockRecord() throws {
        
        // Given
        let app = try ConnectedApp()
        let recordID = "0011Y00003HVMu4FAN"
        let session = mockURLSession(protocolClasses: [MockURLProtocol.self])
        
        // When
        MockURLProtocol.requestHandler = {request in
            let data: Data = MockAccountResponse(id: recordID).json.data(using: .utf8)!
            let response = HTTPURLResponse.init(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        let retrievedRecord = try waitFor(app.retrieve(type: "Account", id: recordID, session: session), timeout: 300)

        // Then
        XCTAssertEqual(retrievedRecord.id, recordID)
    }
    
    func testThatItFailsToRetrieveRecord() throws {
        
        // Given
        let app = try ConnectedApp()
        var error: SalesforceError?
        
        // When
        XCTAssertThrowsError(try waitFor(app.retrieve(type: "Account", id: "001IdThatDoesNotExist"), timeout: 300)) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error?.code.uppercased(), "NOT_FOUND")
    }
    
    func testThatItInsertsRecord() throws {
        
        // Given
        let uuid = UUID().uuidString
        let app = try ConnectedApp()
        let fields = [
            "Name": "Acme Construction Co., Inc.",
            "BillingStreet": uuid,
            "BillingState": "FL",
            "ShippingCity": "Boston"
        ]
        
        // When
        let id: String = try waitFor(app.insert(type: "Account", fields: fields), timeout: 300)
        let retrievedRecord = try waitFor(app.retrieve(type: "Account", id: id))
        
        // Then
        XCTAssert(retrievedRecord["Name"] as String? == "Acme Construction Co., Inc.")
        XCTAssert(retrievedRecord["BillingStreet"] as String? == uuid)
        XCTAssert(retrievedRecord["BillingState"] as String? == "FL")
        XCTAssert(retrievedRecord["ShippingCity"] as String? == "Boston")
    }
    
    func testThatItFailsToInsertRecord() throws {
        
        // Given
        let app = try ConnectedApp()
        var error: SalesforceError?
        let fields = [ // Required "Name" is missing
            "BillingStreet": "123 Main St.",
            "BillingState": "FL",
            "ShippingCity": "Boston"
        ]
        
        // When
        XCTAssertThrowsError(try waitFor(app.insert(type: "Account", fields: fields), timeout: 300)) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error?.code.uppercased(), "REQUIRED_FIELD_MISSING")
        XCTAssert(error!.fields!.contains("Name"))
    }
    
    func testThatItUpdatesRecord() throws {
        
        // Given
        let app = try ConnectedApp()
        let fields = [
            "Name": "Acme Construction Co., Inc.",
            "BillingState": "FL",
        ]
        
        // When
        let id: String = try waitFor(app.insert(type: "Account", fields: fields, allowsLogin: true), timeout: 300)
        try waitFor(app.update(type: "Account", id: id, fields: ["BillingState": "IL", "BillingCity": "Chicago"]), timeout: 300)
        let retrievedRecord = try waitFor(app.retrieve(type: "Account", id: id), timeout: 300)
        
        // Then
        XCTAssert(retrievedRecord.string(forField: "BillingState") == "IL")
        XCTAssert(retrievedRecord.string(forField: "BillingCity") == "Chicago")
    }
    
    func testThatItDeletesRecord() throws {
        
        // Given
        let app = try ConnectedApp()
        let fields = [
            "Name": "Acme Construction Co., Inc.",
            "BillingState": "FL",
        ]
        var error: SalesforceError?
        
        // When
        let id: String = try waitFor(app.insert(type: "Account", fields: fields, allowsLogin: true), timeout: 300)
        try waitFor(app.delete(type: "Account", id: id), timeout: 300)
        XCTAssertThrowsError(try waitFor(app.retrieve(type: "Account", id: id), timeout: 300)) {
            error = ($0 as! SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error?.code.uppercased(), "NOT_FOUND")
    }
    
    func testThatItDescribesSObject() throws {
        
        // Given
        let app = try ConnectedApp()

        // When
        let metadata = try waitFor(app.describe(type: "Account"), timeout: 300)
        
        // Then
        XCTAssert(metadata.name == "Account")
        XCTAssert(metadata.keyPrefix! == "001")
        XCTAssert(metadata.keyPrefix! == metadata.idPrefix!)
        XCTAssert(metadata.pluralLabel == metadata.labelPlural)
    }
    
    func testThatItFailsToDescribesSObject() throws {
        
        // Given
        let app = try ConnectedApp()
        var error: SalesforceError?
        
        // When
        XCTAssertThrowsError(try waitFor(app.describe(type: "ObjectThatDoesNotExist"), timeout: 300)) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error?.code.uppercased(), "NOT_FOUND")
    }
    
    func testThatItDescribesAllSObjects() throws {
        
        // Given
        let app = try ConnectedApp()

        // When
        let metadatas = try waitFor(app.describeAll(), timeout: 300)
        
        // Then
        XCTAssert(metadatas.count > 0)
    }
}
