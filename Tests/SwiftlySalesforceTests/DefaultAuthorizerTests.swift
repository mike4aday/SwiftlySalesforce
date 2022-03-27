import XCTest
@testable import SwiftlySalesforce

class DefaultAuthorizerTests: XCTestCase {
    
    // Note: user must successfully authenticate for the test to pass
    func testThatItAuthenticates() async throws {
        
        // Given
        let config = try loadConfiguration()
        let authorizer = DefaultAuthorizer(consumerKey: config.consumerKey, callbackURL: config.callbackURL)
        
        // When
        let credential = try await authorizer.grantCredential(refreshing: nil)
        
        // Then
        XCTAssertNotNil(credential)
    }
    
    // Note: testing user must successfully authenticate for this test to pass
    func testThatItAuthenticatesConcurrently() async throws {
        
        // Given
        let config = try loadConfiguration()
        let authorizer = DefaultAuthorizer(consumerKey: config.consumerKey, callbackURL: config.callbackURL)
        let taskCount = 30
        
        // When
        let credentials = try await withThrowingTaskGroup(of: Credential.self) { group -> [Credential] in
        
            var creds = [Credential]()
            creds.reserveCapacity(taskCount)
            
            for _ in 0..<taskCount {
                group.addTask {
                    return try await authorizer.grantCredential(refreshing: nil)
                }
            }
            
            for try await cred in group {
                creds.append(cred)
            }
            return creds
        }
        
        // Then
        XCTAssertTrue(credentials.dropLast().allSatisfy { $0 == credentials.last })
    }
    
    // Note: testing user must successfully authenticate for this test to pass
    func testThatItLogsInAndRefreshesConcurrently() async throws {
        
        // Given
        let config = try loadConfiguration()
        let authorizer = DefaultAuthorizer(consumerKey: config.consumerKey, callbackURL: config.callbackURL)
        let initialCredential = try await authorizer.grantCredential(refreshing: nil)
        let taskCount = 30
        
        // When
        let credentials = try await withThrowingTaskGroup(of: Credential.self) { group -> [Credential] in
        
            var creds = [Credential]()
            creds.reserveCapacity(taskCount)
            
            for n in 0..<taskCount {
                group.addTask {
                    return try await authorizer.grantCredential(refreshing: n % 2 == 0 ? initialCredential : nil)
                }
            }
            
            for try await cred in group {
                creds.append(cred)
            }
            return creds
        }
        
        // Then
        XCTAssertTrue(credentials.dropLast().allSatisfy { $0 == credentials.last })
    }
}
