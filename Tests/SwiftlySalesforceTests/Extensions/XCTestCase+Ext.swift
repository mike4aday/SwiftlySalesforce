// Borrowed from: https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/

import Foundation
import XCTest
import Combine

extension XCTestCase {
    
    func waitFor<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
    
    // Borrowed from: https://www.swiftbysundell.com/articles/testing-error-code-paths-in-swift/
    func assert<T, E: Error & Equatable>(
            _ expression: @autoclosure () throws -> T,
            throws error: E,
            in file: StaticString = #file,
            line: UInt = #line
        ) {
            var thrownError: Error?

            XCTAssertThrowsError(try expression(),
                                 file: file, line: line) {
                thrownError = $0
            }

            XCTAssertTrue(
                thrownError is E,
                "Unexpected error type: \(type(of: thrownError))",
                file: file, line: line
            )

            XCTAssertEqual(
                thrownError as? E, error,
                file: file, line: line
            )
        }
    
    func mockURLSession(protocolClasses: [AnyClass] = [MockURLProtocol.self]) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = protocolClasses
        return URLSession(configuration: config)
    }
}
