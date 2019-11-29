//
//  Salesforce+CRUD.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

extension Salesforce {
    
    // MARK: - Retrieve record -
    
    /// Asynchronously retrieves a single record.
    /// - Parameter object: Object type, e.g. "Account", "Contact" or "MyCustomObject__c"
    /// - Parameter id: ID of the record to retrieve
    /// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
    /// - Parameter config: Request configuration
    public func retrieve<T: Decodable>(object: String, id: String, fields: [String]? = nil, config: RequestConfig = .shared) -> AnyPublisher<T, Error> {
        let resource = Endpoint.retrieve(type: object, id: id, fields: fields, version: config.version)
        return request(requestConvertible: resource, config: config)
    }
    
    /// Asynchronously retrieves a single record.
    /// - Parameter object: Object type, e.g. "Account", "Contact" or "MyCustomObject__c"
    /// - Parameter id: ID of the record to retrieve
    /// - Parameter fields: Optional array of field names to retrieve. If nil, all fields will be retrieved
    /// - Parameter config: Request configuration
    public func retrieve(object: String, id: String, fields: [String]? = nil, config: RequestConfig = .shared) -> AnyPublisher<Record, Error> {
        let resource = Endpoint.retrieve(type: object, id: id, fields: fields, version: config.version)
        return request(requestConvertible: resource, config: config)
    }
    
    // MARK: - Insert record -
    
    /// Asynchronously creates a new record in Salesforce
    /// - Parameter record: Record to be inserted in Salesforce. Must conform to EncodableRecord protocol
    /// - Parameter config: Request configuration
    public func insert<T: EncodableRecord>(record: T, config: RequestConfig = .shared) -> AnyPublisher<String, Error> {
        return Just(record)
            .tryMap { (record) -> URLRequestConvertible in
                guard record.id == nil else {
                    throw SalesforceError.invalidRequest(message: "Record ID must not be set for insert.")
                }
                let data = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(record)
                return Endpoint.insert(type: record.object, data: data, version: config.version)
            }
            .flatMap { (resource) -> AnyPublisher<InsertResult, Error>  in
                self.request(requestConvertible: resource, config: config)
            }
            .map { return $0.id }
            .eraseToAnyPublisher()
    }
    
    /// Asynchronously creates a new record in Salesforce
    /// - Parameter object: Object type, e.g. "Account", "Contact" or "MyCustomObject__c"
    /// - Parameter fields: Dictionary of field names and values to be set on the newly-inserted record.
    /// - Parameter config: Request configuration
    public func insert(object: String, fields: [String: Encodable?], config: RequestConfig = .shared) -> AnyPublisher<String, Error> {
        let record = Record(object: object, fields: fields)
        return insert(record: record, config: config)
    }
    
    // MARK: - Update record -
    
    /// Asynchronously updates a record in Salesforce
    /// - Parameter record: Record to be updated
    /// - Parameter config: Request configuration
    public func update<T: EncodableRecord>(record: T, config: RequestConfig = .shared) -> AnyPublisher<Void, Error> {
        return Just(record)
            .tryMap { (record) -> URLRequestConvertible in
                let data = try JSONEncoder(dateFormatter: .salesforceDateTimeFormatter).encode(record)
                guard let id = record.id else {
                    throw SalesforceError.invalidRequest(message: "Record ID required for update.")
                }
                return Endpoint.update(type: record.object, id: id, data: data, version: config.version)
            }
            .flatMap { (resource) -> AnyPublisher<Data, Error>  in
                self.request(requestConvertible: resource, config: config)
            }
            .map { _ in return }
            .eraseToAnyPublisher()
    }
    
    /// Asynchronously updates a record in Salesforce
    /// - Parameter object: Object type, e.g. "Account", "Contact" or "MyCustomObject__c"
    /// - Parameter id: ID of the record to update
    /// - Parameter fields: Dictionary of updated field name and value pairs.
    /// - Parameter config: Request configuration
    public func update(object: String, id: String, fields: [String: Encodable?], config: RequestConfig = .shared) -> AnyPublisher<Void, Error> {
        let record = Record(object: object, id: id, fields: fields)
        return update(record: record, config: config)
    }
        
    // MARK: - Delete record -
    
    /// Asynchronously deletes a record from Salesforce
    /// - Parameter record: Record to be deleted
    /// - Parameter config: Request configuration
    public func delete<T: EncodableRecord>(record: T, config: RequestConfig = .shared) -> AnyPublisher<Void, Error> {
        return Just(record)
            .tryMap { (record) -> URLRequestConvertible in
                guard let id = record.id else {
                    throw SalesforceError.invalidRequest(message: "Record ID required for delete.")
                }
                return Endpoint.delete(type: record.object, id: id, version: config.version)
            }
            .flatMap { (resource) -> AnyPublisher<Data, Error>  in
                self.request(requestConvertible: resource, config: config)
            }
            .map { _ in return }
            .eraseToAnyPublisher()
    }
    
    /// Asynchronously deletes a record from Salesforce
    /// - Parameter object: Object type, e.g. "Account", "Contact" or "MyCustomObject__c"
    /// - Parameter id: ID of the record to be deleted
    /// - Parameter config: Request configuration
    public func delete(object: String, id: String, config: RequestConfig = .shared) -> AnyPublisher<Void, Error> {
        let record = Record(object: object, id: id)
        return delete(record: record, config: config)
    }
}

// MARK: - Internal-use, decodable models -

fileprivate extension Salesforce {
        
    struct InsertResult: Decodable {
        var id: String
    }
}
