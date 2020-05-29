//
//  Salesforce+DescribeLayout.swift
//  SFDC Tool
//
//  Created by Alexey Malashin on 28.05.2020.
//  Copyright © 2020 Alexey Malashin. All rights reserved.
//

import Foundation
import Combine
import SwiftlySalesforce

extension Salesforce {
    public func describeLayout(object: String, id: String, config: RequestConfig = .shared) -> AnyPublisher<ObjectLayout, Error> {
        let resource = Endpoint.describeLayout(type: object, version: config.version, id: id)
        return request(requestConvertible: resource, config: config)
    }
}
