//
//  PicklistItem.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

/// Represents an option in a Salesforce Picklist-type field (i.e. drop-down list); used with ObjectDescription
public struct PicklistItem: Decodable {
    
    public let isActive: Bool
    public let isDefault: Bool
    public let label: String
    public let value: String
    
    enum CodingKeys: String, CodingKey {
        case isActive = "active"
        case isDefault = "defaultValue"
        case label
        case value
    }
}
