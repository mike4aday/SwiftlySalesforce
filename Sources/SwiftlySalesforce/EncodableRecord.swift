//
//  EncodableRecord.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

/// This protocol should be adopted by any custom model objects that will be saved to Salesforce during record insert, update or delete operations.
public protocol EncodableRecord: Encodable {
    var object: String { get }
    var id: String? { get }
}
