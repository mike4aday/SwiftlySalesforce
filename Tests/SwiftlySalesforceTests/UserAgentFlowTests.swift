import XCTest
import Combine
@testable import SwiftlySalesforce

class UserAgentFlowTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }

    func testThatItAuthenticates() {
        
        // Given
        let connectedApp = Util.connectedApp
        let exp = expectation(description: "Authentication")
        
        // When
        let pub = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        
        // Then
        pub.sink(receiveCompletion: { (completion) in
            exp.fulfill()
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
        }) { (credential) in
            XCTAssertNotNil(credential.accessToken)
            XCTAssertNotNil(credential.identityURL)
        }.store(in: &subscriptions)
        
        waitForExpectations(timeout: 120, handler: nil)
    }
    
    func testThatItAuthenticatesMultipleTimesSimultaneously() {
        
        // Given
        let connectedApp = Util.connectedApp
        let exp = expectation(description: "Authentication")
        
        // When
        let pub1 = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        let pub2 = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        let pub3 = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        let pub4 = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        
        // Then
        pub1.zip(pub2, pub3, pub4).sink(receiveCompletion: { (completion) in
            exp.fulfill()
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
        }) { (credentials) in
            XCTAssertNotNil(credentials.0.accessToken)
            XCTAssertNotNil(credentials.1.accessToken)
            XCTAssertNotNil(credentials.2.accessToken)
            XCTAssertNotNil(credentials.3.accessToken)
            XCTAssertEqual(credentials.0.accessToken, credentials.1.accessToken)
            XCTAssertEqual(credentials.0.accessToken, credentials.2.accessToken)
            XCTAssertEqual(credentials.0.accessToken, credentials.3.accessToken)
        }.store(in: &subscriptions)
        
        // Verify that all publishers are same instance
        XCTAssertEqual(ObjectIdentifier(pub1 as AnyObject), ObjectIdentifier(pub2 as AnyObject))
        XCTAssertEqual(ObjectIdentifier(pub1 as AnyObject), ObjectIdentifier(pub3 as AnyObject))
        XCTAssertEqual(ObjectIdentifier(pub1 as AnyObject), ObjectIdentifier(pub4 as AnyObject))
        
        waitForExpectations(timeout: 120, handler: nil)
    }
}
