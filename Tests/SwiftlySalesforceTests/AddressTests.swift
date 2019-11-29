import Foundation
import XCTest
@testable import SwiftlySalesforce

class AddressTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatAddressInitsWithJSON() {
    
        // Given
        let data = json.data(using: .utf8)!
        
        // When
        let address = try! Mocker.jsonDecoder.decode(Address.self, from: data)
                
        // Then
        XCTAssertEqual("Burlington", address.city)
        XCTAssertEqual("USA", address.country)
        XCTAssertNil(address.countryCode)
        XCTAssertEqual(Address.GeocodeAccuracy.block, address.geocodeAccuracy)
        XCTAssertEqual(36.090709, address.latitude)
        XCTAssertEqual(-79.437266, address.longitude)
        XCTAssertEqual("27215", address.postalCode)
        XCTAssertEqual("NC", address.state)
        XCTAssertNil(address.stateCode)
        XCTAssertEqual("525 S. Lexington Ave.", address.street)
    }
    
    let json = """
    {
        "city" : "Burlington",
        "country" : "USA",
        "countryCode" : null,
        "geocodeAccuracy" : "Block",
        "latitude" : 36.090709,
        "longitude" : -79.437266,
        "postalCode" : "27215",
        "state" : "NC",
        "stateCode" : null,
        "street" : "525 S. Lexington Ave."
    }
    """
}
