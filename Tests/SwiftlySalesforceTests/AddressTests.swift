import XCTest
@testable import SwiftlySalesforce

class AddressTests: XCTestCase {

    func testThatItInitializes() throws {
        
        // Given
        let data = try load(resource: "MockAccount")
        let decoder = JSONDecoder(dateFormatter: .salesforce(.long))
        
        // When
        let account = try decoder.decode(Record.self, from: data)
        let billingAddress = account.address(forField: "BillingAddress")
        
        // Then
        XCTAssertNotNil(billingAddress)
        XCTAssertEqual(billingAddress?.state, "AK")
    }
}
