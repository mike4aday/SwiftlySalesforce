import XCTest
@testable import SwiftlySalesforce

class LimitTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testThatItDecodesLimits() {
        
        // Given
        let data = Mocker.limits.data(using: .utf8)!
        
        // When
        let limits = try! Mocker.jsonDecoder.decode([String: Limit].self, from: data)
        let apiLimit = limits["DailyApiRequests"]!
        let streamingLimit = limits["DailyDurableGenericStreamingApiEvents"]!
        
        // Then
        XCTAssertEqual(apiLimit.maximum, 15000)
        XCTAssertEqual(apiLimit.remaining, 14980)
        XCTAssertEqual(apiLimit.used, 20)
        XCTAssertEqual(streamingLimit.maximum, 10000)
        XCTAssertEqual(streamingLimit.remaining, 10000)
        XCTAssertEqual(streamingLimit.used, 0)
    }
}
