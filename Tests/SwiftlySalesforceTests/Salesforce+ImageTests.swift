import XCTest
import Combine
@testable import SwiftlySalesforce

class Salesforce_ImageTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }

    func testThatItGetsSmallImage() {
        
        // Given
        let sfdc = Util.salesforce
        
        // When
        let pub = sfdc.identity().flatMap { identity -> AnyPublisher<UIImage, Error> in
            guard let url = identity.thumbnailURL else {
                return Fail<UIImage, Error>(error: URLError(URLError.badURL)).eraseToAnyPublisher()
            }
            return sfdc.fetchImage(url: url)
        }
        
        // Then
        let exp = expectation(description: "Get thumbnail image")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { image in
            XCTAssertTrue(image.size.width > 0)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
}
