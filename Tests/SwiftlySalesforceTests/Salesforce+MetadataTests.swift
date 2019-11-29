import XCTest
import Combine
@testable import SwiftlySalesforce

class Salesforce_MetadataTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }

    func testThatItDescribesObject() {
        
        // Given
        let sfdc = Util.salesforce
           
        // When
        let pub = sfdc.describe(object: "Account")
        
        // Then
        let exp = expectation(description: "Get Account metadata")
        pub.sink(receiveCompletion: { (completion) in
           switch completion {
           case let .failure(error):
               XCTFail("\(error)")
           case .finished:
               break
           }
           exp.fulfill()
        }, receiveValue: { description in
            XCTAssertFalse(description.isCustom)
            XCTAssertEqual(description.name, "Account")
            XCTAssertEqual(description.keyPrefix, "001")
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testThatItFailsToDescribeNonexistentObject() {
        
        // Given
        let sfdc = Util.salesforce
           
        // When
        let pub = sfdc.describe(object: "NonexistenObject")
        
        // Then
        let exp = expectation(description: "Try to get non-existent object metadata")
        pub.sink(receiveCompletion: { (completion) in
           switch completion {
           case .failure:
                // Expected to fail
                break
           case .finished:
                break
           }
           exp.fulfill()
        }, receiveValue: { description in
            XCTFail("Shouldn't be able to desscribe non-existen object")
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testThatItDescribesAllObjects() {
        
        // Given
        let sfdc = Util.salesforce
           
        // When
        let pub = sfdc.describeAllObjects()
        
        // Then
        let exp = expectation(description: "Get metadata for all objects")
        pub.sink(receiveCompletion: { (completion) in
           switch completion {
           case let .failure(error):
               XCTFail("\(error)")
           case .finished:
               break
           }
           exp.fulfill()
        }, receiveValue: { descriptions in
            XCTAssertNotNil(descriptions.filter { $0.name == "Account" }.first)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
}
