/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

public extension ConnectedApp {
    
    /// Retrieves a Salesforce record
    /// - Parameters:
    ///   - type: Type of record (e.g. "Account", "Contact" or "MyCustomObject__c").
    ///   - id: Unique ID of the record; 15 or 18 characters.
    ///   - fields: Fields to retrieve. If nil, then all fields will be retrieved.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher of a Record
    /// # Reference
    /// [Working with Records](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/using_resources_working_with_records.htm)
    func retrieve(type: String, id: String, fields: [String]? = nil, session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<Record, Error> {
        go(service: SObjectsService(.read(type: type, id: id, fields: fields)), session: session, allowsLogin: allowsLogin)
    }
    
    /// Inserts a Salesforce record
    /// - Parameters:
    ///   - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///   - fields: Dictionary of fields names and values to insert.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher that emits the ID of the successfully-inserted record, or an error.
    func insert<T: Encodable>(type: String, fields: [String:T], session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<String, Error> {
        AnyPublisher<SObjectsService, Error>
            .just(try SObjectsService(.create(type: type, fields: fields)))
            .flatMap { go(service: $0, session: session, allowsLogin: allowsLogin) }
            .map { (output: CreateSObjectResult) -> String in
                output.id
            }
            .eraseToAnyPublisher()
    }
    
    /// Updates a Salesforce record
    /// - Parameters:
    ///   - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///   - id: Unique ID of the record; 15 or 18 characters.
    ///   - fields: Dictionary of fields names and values to update.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher.
    func update<T: Encodable>(type: String, id: String, fields: [String:T], session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<Void, Error> {
        AnyPublisher<SObjectsService, Error>
            .just(try SObjectsService(.update(type: type, id: id, fields: fields)))
            .flatMap { go(service: $0, session: session, allowsLogin: allowsLogin) }
            .map { (_: Data) in return }
            .eraseToAnyPublisher()
    }
    
    /// Deletes a Salesforce record
    /// - Parameters:
    ///   - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///   - id: Unique ID of the record; 15 or 18 characters.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher.
    func delete(type: String, id: String, session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<Void, Error> {
        go(service: SObjectsService(.delete(type: type, id: id)), session: session, allowsLogin: allowsLogin)
            .map { (_: Data) in return }
            .eraseToAnyPublisher()
    }
    
    /// Retrieves metadata about a Salesforce object
    /// - Parameters:
    ///   - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher of metadata about the object.
    /// # Reference
    /// [sObject Describe](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm)
    func describe(type: String, session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<ObjectDescription, Error> {
        go(service: SObjectsService(.describe(type: type)), session: session, allowsLogin: allowsLogin)
    }
    
    /// Describes all accessible objects in the user's Salesforce org
    /// - Parameters:
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher of an array of object metadata.
    func describeAll(session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<[ObjectDescription], Error> {
        struct DescribeAllResult: Decodable {
            var sobjects: [ObjectDescription]
        }
        return go(service: SObjectsService(.describeAll), session: session, allowsLogin: allowsLogin)
            .map { (result: DescribeAllResult) -> [ObjectDescription] in
                return result.sobjects
            }
            .eraseToAnyPublisher()
    }
}

fileprivate struct CreateSObjectResult: Decodable {
    var id: String
    var errors: [SalesforceError]
    var success: Bool
}
