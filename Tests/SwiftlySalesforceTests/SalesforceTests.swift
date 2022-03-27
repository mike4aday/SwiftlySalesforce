import XCTest
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThatItConnectsWithConfigURL() throws {
        
        // Given
        let url = Bundle(for: type(of: self)).url(forResource: "MockConfig", withExtension: "json")!
        
        // When
        let connection = try Salesforce.connect(configurationURL: url)
        
        // Then
        XCTAssertNotNil(connection.authorizer)
        XCTAssertTrue(connection.authorizer is DefaultAuthorizer)
        XCTAssertTrue(connection.credentialStore is DefaultCredentialStore)
    }
    
    func testThatItConnectsWithDefaultConfig() throws {
        
        // Given
        
        // When
        let connection = try Salesforce.connect()
        
        // Then
        XCTAssertNotNil(connection.authorizer)
        XCTAssertTrue(connection.authorizer is DefaultAuthorizer)
        XCTAssertTrue(connection.credentialStore is DefaultCredentialStore)
    }

    func testThatItConnectsWithArguments() throws {
        
        // Given
        let consumerKey = "CONSUMER_KEY"
        let callbackURL = URL(string: "callback://done")!
        let authHost = "auth.salesforce.com"
        
        // When
        let connection = try Salesforce.connect(consumerKey: consumerKey, callbackURL: callbackURL, authorizingHost: authHost)
        
        // Then
        XCTAssertNotNil(connection.authorizer)
        XCTAssertTrue(connection.authorizer is DefaultAuthorizer)
        XCTAssertTrue(connection.credentialStore is DefaultCredentialStore)
    }
}
