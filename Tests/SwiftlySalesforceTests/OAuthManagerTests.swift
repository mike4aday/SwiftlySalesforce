import XCTest
import Combine
@testable import SwiftlySalesforce

class OAuthManagerTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }

    func testThatItRevokesRefreshToken() {
        
        // Given
        let sfdc = Util.salesforce
        let mgr = sfdc.oAuthManager
        let config = Salesforce.RequestConfig(version: "47.0", session: URLSession.shared, authenticateIfRequired: false, retries: 0)
        
        // When
        let pub = sfdc.identity()
        .flatMap { _ in
            mgr.revoke(token: sfdc.credential!.refreshToken!)
        }
        .flatMap { _ in
            sfdc.identity(config: config)
        }
        
        // Then
        let exp = expectation(description: "Revoke access token")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                switch error {
                case SalesforceError.authenticationRequired, RefreshTokenFlowError.endpointFailure:
                    break
                default:
                    XCTFail("\(error)")
                }
            case .finished:
                XCTFail("Should have failed")
            }
            exp.fulfill()
        }, receiveValue: { _ in
            return XCTFail("Should have failed")
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 360, handler: nil)
    }
}
