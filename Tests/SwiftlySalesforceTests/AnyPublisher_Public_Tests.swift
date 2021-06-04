/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class AnyPublisher_Public_Tests: XCTestCase {
    
    func testJustPublisher() throws {
        
        // Given
        let s = "Hello World!"
        
        // When
        let output = try waitFor(AnyPublisher<String, Never>.just(s))
        
        // Then
        XCTAssertEqual(s, output)
    }
    
    func testJustClosurePublisher() throws {
        
        // Given
        struct MyNumber: Equatable {
            var x: Int
            init(_ x: Int?) throws {
                guard let x = x else { throw URLError(.badURL) }
                self.x = x
            }
        }
        
        // When
        let output = try waitFor(AnyPublisher<MyNumber, Error>.just(try MyNumber(3)))
        
        // Then
        XCTAssertEqual(output, try! MyNumber(3))
    }
    
    func testFailPublisher() throws {
        let error = URLError(.badURL)
        XCTAssertThrowsError(try waitFor(AnyPublisher<Void, Error>.fail(with: error)))
    }
}
