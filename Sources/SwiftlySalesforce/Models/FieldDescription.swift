//
//  File.swift
//  
//
//  Created by Michael Epstein on 4/25/21.
//

import Foundation

/// Salesforce field metadata.
/// See [SObject Describe](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm).
public struct FieldDescription {
    
    @DefaultValueEncoded
    public var defaultValue: Any?
    
    public let defaultValueFormula: String?
    public let inlineHelpText: String?
    public let isCreateable: Bool
    public let isCustom: Bool
    public let isEncrypted: Bool
    public let isNillable: Bool
    public let isSortable: Bool
    public let isUpdateable: Bool
    public let label: String
    public let length: UInt?
    public let name: String
    public let picklistValues: [PicklistItem]
    public let relatedTypes: [String]
    public let relationshipName: String?
    public let type: String
    
    public var helpText: String? {
        return inlineHelpText
    }
    
    public var referenceTo: [String]? {
        return relatedTypes
    }
}

extension FieldDescription: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case defaultValue
        case defaultValueFormula
        case inlineHelpText
        case isCreateable = "createable"
        case isCustom = "custom"
        case isEncrypted = "encrypted"
        case isNillable = "nillable"
        case isSortable = "sortable"
        case isUpdateable = "updateable"
        case label
        case length
        case name
        case picklistValues
        case relatedTypes = "referenceTo"
        case relationshipName
        case type
    }
}

@propertyWrapper
public struct DefaultValueEncoded: Decodable {
    
    public var wrappedValue: Any? = nil
    
    public init(from decoder: Decoder) throws {
        // 'defaultValue' can be either String (for Picklist-type fields) or Boolean (for Checkbox-type fields).
        // All other field types store their default values in 'defaultValueFormula'...
        let container = try decoder.singleValueContainer()
        if let f = try? container.decode(Bool.self) {
            self.wrappedValue = f
        }
        else if let s = try? container.decode(String.self) {
            self.wrappedValue = s
        }
    }
}
