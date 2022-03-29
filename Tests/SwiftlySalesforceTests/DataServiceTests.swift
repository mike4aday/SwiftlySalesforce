import XCTest
@testable import SwiftlySalesforce

class DataServiceTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        MockURLProtocol.loadingHandler = nil
    }

    override func tearDownWithError() throws {
        MockURLProtocol.loadingHandler = nil
        try super.tearDownWithError()
    }
}
