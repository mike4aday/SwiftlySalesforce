import XCTest
import Combine
@testable import SwiftlySalesforce

class Salesforce_SearchTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }
    
    // Assumption: existing records that match search criteria
    func testThatItSearches() {
        
        // Given
        let sfdc = Util.salesforce
        let sosl = """
            FIND {"A*" OR "B*" OR "C*" OR "D*"} IN Name Fields RETURNING Lead(name,phone,Id), Contact(name,phone)
        """
        
        // When
        let pub = sfdc.search(sosl: sosl)
        
        // Then
        let exp = expectation(description: "Search for leads and contacts")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { results in
            for record in results {
                XCTAssertTrue(record.object.lowercased() == "lead" || record.object.lowercased() == "contact")
                XCTAssertNotNil(record.id)
                XCTAssertNotNil(record.string(forField: "Name"))
            }
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
}
