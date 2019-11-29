import XCTest
import Combine
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func testThatItGetsLimits() {
        
        // Given
        let sfdc = Util.salesforce
        
        // When
        let pub = sfdc.limits()
        
        // Then
        let exp = expectation(description: "Get limits")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { limits in
            XCTAssertTrue(limits.count > 0)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 360, handler: nil)
    }
    
    func testThatItGetsIdentity() {
        
        // Given
        let sfdc = Util.salesforce
        
        // When
        let pub = sfdc.identity()
        
        // Then
        let exp = expectation(description: "Get identity")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { identity in
            XCTAssertNotNil(identity.userID)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testThatItGetsOrgInfo() {
        
        // Given
        let sfdc = Util.salesforce
        
        // When
        let pub = sfdc.org()
        
        // Then
        let exp = expectation(description: "Get org info")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { org in
            XCTAssertNotNil(org.id)
            XCTAssertTrue(org.id.starts(with: "00D"))
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    // Assumption: some account records exist in org
    func testThatItInvokesAPEXRest() {
        
        // Given
        let sfdc = Util.salesforce
        struct Account: Decodable {
            var Id: String
            var Name: String
        }
        
        // When
        let exp = expectation(description: "Invoke Apex REST method")
        sfdc.query(soql: "SELECT Id FROM Account LIMIT 1")
        .flatMap { (queryResult) -> AnyPublisher<Account, Error> in
            let id = queryResult.records[0].id!
            return sfdc.apex(method: .get, path: "/playgroundorg/Account/\(id)")
        }
        .sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }) { (acct) in
            XCTAssertNotNil(acct.Id)
        }
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
}
