/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine
import XCTest
@testable import SwiftlySalesforce

class CredentialManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testThatItGetsCredential() throws {
        
        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager

        // When
        let credential = try waitFor(mgr.getCredential(), timeout: 300)
        
        // Then
        XCTAssertNotNil(credential)
    }
    
    func testThatItGetsStoredCredential() throws {

        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager
        let _ = try waitFor(app.identity(), timeout: 300)

        // When
        let storedCredential = try mgr.getStoredCredential()

        // Then
        XCTAssertNotNil(storedCredential)
    }

    func testThatItFailsToGetStoredCredential() throws {

        // Given
        let userID = UUID().uuidString
        let orgID = UUID().uuidString
        let user = UserIdentifier(userID: userID, orgID: orgID)!
        let callbackURL = URL(string: "myapp://callback")!
        let mgr = CredentialManager(consumerKey: "consumer-key", callbackURL: callbackURL)

        // When
        let credential = try mgr.getStoredCredential(for: user)

        // Then
        XCTAssertNil(credential)
    }
    
    func testThatItGetsNewCredential() throws {

        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager

        // When
        let oldCredential: Credential? = try mgr.getStoredCredential()
        let newCredential: Credential = try waitFor(mgr.grantCredential(replacing: oldCredential, allowsLogin: true), timeout: 300)

        // Then
        XCTAssertNotNil(newCredential)
        if let oldTimestamp = oldCredential?.timestamp, let newTimestamp = newCredential.timestamp {
            XCTAssert(oldTimestamp < newTimestamp)
        }
    }
    
    func testThatItAuthenticates() throws {
        
        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager

        // When
        let newCredential: Credential = try waitFor(mgr.grantCredential(replacing: nil, allowsLogin: true), timeout: 300)

        // Then
        XCTAssertNotNil(newCredential)
    }
    
    func testThatMultipleGrantRequestsAreShared() throws {

        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager

        // When
        let publishers: [AnyPublisher<Credential, Error>] = (0...9).map { x in
            let queue = DispatchQueue(label: "Queue \(x) (ID: \(UUID().uuidString))")
            return mgr
                .grantCredential(replacing: nil, allowsLogin: true)
                .receive(on: queue)
                .onCompletion {
                    _ in debugPrint("Queue completed \(queue.label)")
                }
                .eraseToAnyPublisher()
        }
        let megaPub = Publishers.Sequence(sequence: publishers)
            .flatMap{ $0 }
            .collect()
        let credentials = try waitFor(megaPub, timeout: 300)
        let comparator = credentials[0]

        // Then
        XCTAssertEqual(credentials.count, publishers.count)
        XCTAssert(credentials.allSatisfy { comparator == $0 })
    }
    
    func testThatMultipleRefreshesAreShared() throws {

        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager

        // When
        let credential = try waitFor(mgr.getCredential(), timeout: 300)
        let publishers: [AnyPublisher<Credential, Error>] = (0...9).map { x in
            let queue = DispatchQueue(label: "Queue \(x) (ID: \(UUID().uuidString))")
            return mgr
                .grantCredential(replacing: credential, allowsLogin: false)
                .receive(on: queue)
                .handleEvents(
                    receiveCompletion: { _ in
                        debugPrint("Queue completed \(queue.label)")
                    }
                )
                .eraseToAnyPublisher()
        }
        let megaPub = Publishers.Sequence(sequence: publishers)
            .flatMap{ $0 }
            .collect()
        let credentials = try waitFor(megaPub, timeout: 300)
        let comparator = credentials[0]

        // Then
        XCTAssertEqual(credentials.count, publishers.count)
        XCTAssert(credentials.allSatisfy { comparator == $0 })
    }
    
    func testThatMultipleRevokesAreShared() throws {

        // Given
        let app = try ConnectedApp()
        let mgr = app.credentialManager

        // When
        let credential = try waitFor(mgr.getCredential(), timeout: 300)
        let publishers: [AnyPublisher<Void, Error>] = (0...9).map { x in
            let queue = DispatchQueue(label: "Queue \(x) (ID: \(UUID().uuidString))")
            return mgr
                .revokeCredential(credential)
                .receive(on: queue)
                .handleEvents(
                    receiveCompletion: { _ in
                        debugPrint("Queue completed \(queue.label)")
                    }
                )
                .eraseToAnyPublisher()
        }
        let megaPub = Publishers.Sequence(sequence: publishers)
            .flatMap{ $0 }
            .collect()
        let results: [Void] = try waitFor(megaPub, timeout: 300)

        // Then
        XCTAssertEqual(results.count, publishers.count)
    }
    
    func testThatItFailsIfLoginDisallowed() throws {
                
        // Given
        let callbackURL = URL(string: "myapp://callback")!
        let mgr = CredentialManager(consumerKey: "consumer-key", callbackURL: callbackURL)
        var error: SalesforceError?
        
        // When
        XCTAssertThrowsError(try waitFor(mgr.grantCredential(replacing: nil, allowsLogin: false))) {
            error = ($0 as? SalesforceError)
        }
        
        // Then
        XCTAssertEqual(error, SalesforceError.userAuthenticationRequired)
    }
}
