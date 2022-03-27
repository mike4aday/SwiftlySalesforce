import Foundation
import XCTest
@testable import SwiftlySalesforce

extension XCTestCase {
    
    static var connection: Connection = try! Salesforce.connect()
    
    func load(resource: String, withExtension: String = "json", inBundle: Bundle? = nil) throws -> Data {
        let bundle = inBundle ?? Bundle(for: Self.self)
        guard let url = bundle.url(forResource: resource, withExtension: withExtension) else {
            throw URLError(.fileDoesNotExist, userInfo: [NSURLErrorFailingURLErrorKey: "\(resource).\(withExtension)"])
        }
        return try Data(contentsOf: url)
    }
    
    func loadConfiguration(at url: URL? = nil) throws -> Salesforce.Configuration {
        let data = try load(resource: "Salesforce", inBundle: .main)
        return try JSONDecoder().decode(Salesforce.Configuration.self, from: data)
    }
    
    var mockCredential: Credential {
        return Credential(accessToken: "ACCESS TOKEN", instanceURL: URL(string: "https://na5.salesforce.com")!, identityURL: URL(string: "https://login.salesforce.com/id/:ORGID/:USERID")!, timestamp: Date())
    }
}
