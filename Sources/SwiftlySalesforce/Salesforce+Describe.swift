//
//  Salesforce+Describe.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import Combine

extension Salesforce {
    
    /**
     Asynchronously retrieves metadata about a Salesforce object and its fields.
     See [Get Field and Other Metadata for an Object](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm)
     - Parameter object: Name of Salesforce object
     - Parameter config: Request configuration options
     - Returns: Publisher of ObjectDescription
     */
    public func describe(object: String, config: RequestConfig = .shared) -> AnyPublisher<ObjectDescription, Error> {
        let resource = Endpoint.describe(type: object, version: config.version)
        return request(requestConvertible: resource, config: config)
    }
    
    /**
    Asynchronously retrieves metadata summaries about all Salesforce objects
    See: [Get Field and Other Metadata for an Object](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm)
    - Parameter config: Request configuration options
    - Returns: Publisher of ObjectDescription
    */
    public func describeAllObjects(config: RequestConfig = .shared) -> AnyPublisher<[ObjectDescription], Error> {
        
        struct DescribeAllResult: Decodable {
            var sobjects: [ObjectDescription]
        }
        
        let resource = Endpoint.describeGlobal(version: config.version)
        return request(requestConvertible: resource, config: config)
        .map { (result: DescribeAllResult) -> [ObjectDescription] in
            return result.sobjects
        }
        .eraseToAnyPublisher()
    }
}
