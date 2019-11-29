import XCTest
import Combine
@testable import SwiftlySalesforce

class RefreshTokenFlowTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }

    // Assumption: server grants refresh token
    func testThatItRefreshes() {
        
        // Given
        let connectedApp = Util.connectedApp
        let exp = expectation(description: "Refresh token")
        
        // When
        let pub = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        .flatMap { (cred) -> AnyPublisher<Credential, Error> in
            RefreshTokenFlow().publisher(credential: cred, connectedApp: connectedApp, hostname: "login.salesforce.com")
        }
        .eraseToAnyPublisher()
        
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
        waitForExpectations(timeout: 60 , handler: nil)
    }
    
    // Assumption: server grants refresh token
    func testThatItFailsToRefresh() {
        
        // Given
        let connectedApp = Util.connectedApp
        let exp = expectation(description: "Fails to refresh token")
        
        // When
        let pub = UserAgentFlow().publisher(connectedApp: connectedApp, hostname: "login.salesforce.com")
        .flatMap { (cred) -> AnyPublisher<Credential, Error> in
            let badCred = Credential(accessToken: cred.accessToken,
                                     instanceURL: cred.instanceURL,
                                     identityURL: cred.identityURL,
                                     refreshToken: "NO REFRESH TOKEN",
                                     issuedAt: nil, idToken: nil,
                                     communityURL: nil,
                                     communityID: nil)
            return RefreshTokenFlow().publisher(credential: badCred, connectedApp: connectedApp, hostname: "login.salesforce.com")
        }
        .eraseToAnyPublisher()
        
        // Then
        pub.sink(receiveCompletion: { (completion) in
            exp.fulfill()
            switch completion {
            case let .failure(error):
                // Expected to fail with RefreshTokenFlowError
                guard case RefreshTokenFlowError.endpointFailure = error else {
                    return XCTFail("Should have failed to refresh token")
                }
                break
            case .finished:
                break
            }
        }) { (credential) in
            return XCTFail("Should have failed to refresh token")
        }.store(in: &subscriptions)
        waitForExpectations(timeout: 120, handler: nil)
    }
}
