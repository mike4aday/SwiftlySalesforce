/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class ConnectedApp_Query_Tests: XCTestCase {
    
    func testThatItQueries() throws {
        
        // Given
        let app = try ConnectedApp()
        let soql = "SELECT Id,Name,Website,BillingAddress FROM Account"
        
        // When
        let result = try waitFor(app.query(soql: soql), timeout: 300)
        
        // Then
        debugPrint("Query result: \(result.records.count) records")
        for record in result.records {
            XCTAssertNotNil(record["Name"] as String?)
        }
    }
    
    func testThatItQueriesMyAccounts() throws {
        
        // Given
        let app = try ConnectedApp()

        // When
        let result = try waitFor(app.myRecords(type: "Account"), timeout: 300)
        let identity = try waitFor(app.identity(), timeout: 300)
        
        // Then
        for record in result.records {
            XCTAssertEqual(record["OwnerId"], identity.userID)
        }
    }
    
    func testThatItFailsToQuery() throws {
        
        // Given
        let app = try ConnectedApp()
        let soql = "SELECT Id,Name,Website,BillingAddress FROM ObjectThatDoesNotExist"
        var error: SalesforceError?
        
        // When
        XCTAssertThrowsError(try waitFor(app.query(soql: soql), timeout: 300)) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error?.code.uppercased(), "INVALID_TYPE")
    }
}
