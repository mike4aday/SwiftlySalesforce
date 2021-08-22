//
//  File.swift
//  
//
//  Created by Michael Epstein on 4/27/21.
//

import Foundation

public typealias SObject = Record 
public typealias SalesforceRecord = Record

/// Represents a Salesforce record.
///
/// Field values can be accessed via a number of getter methods, depending on the return type, or via a subscript using the field name as a key.
/// # Example
/// ```
///  var record: SalesforceRecord
///  //...
///  let acctName: String? = record.string(forField: "Name")
///  let alsoAcctName: String? = record["Name"]
/// ```
public struct Record: Decodable {
    
    public let id: String // May be empty string, e.g. for AggregateResult query results
    public let type: String
    private var container: KeyedDecodingContainer<RecordCodingKey>
    
    public init(from decoder: Decoder) throws {
        
        struct Attributes: Decodable {
            var type: String
            var url: String?
        }
            
        container = try decoder.container(keyedBy: RecordCodingKey.self)
        let attributes = try container.decode(Attributes.self, forKey: RecordCodingKey(stringValue: "attributes")!)
            
        // Type of SObject
        self.type = attributes.type
            
        // Record ID
        if let id = try container.decodeIfPresent(String.self, forKey: RecordCodingKey(stringValue: "Id")!) {
            // "Id" was one of the fields queried or retrieved
            self.id = id
        }
        else {
            if let path = attributes.url, let id = path.components(separatedBy: "/").last, id.count == 18 || id.count == 15 {
                // ID can be extracted from the record URL string
                self.id = id
            }
            else {
                // There is no record ID, e.g. in case of AggregateResult of a query
                self.id = ""
            }
        }
    }
    
    public func hasField(named field: String) -> Bool {
        if let key = RecordCodingKey(stringValue: field) {
            return container.contains(key)
        }
        return false
    }

    public func value<Value: Decodable>(forField field: String) throws -> Value? {
        let key = RecordCodingKey(stringValue: field)!
        return try container.decodeIfPresent(Value.self, forKey: key)
    }
    
    public subscript<Value: Decodable>(field: String) -> Value? {
        return try? value(forField: field)
    }
}

public extension Record {
    
    /// Returns the value for the given field as a String
    func string(forField field: String) -> String? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Date
    func date(forField field: String) -> Date? {
        return self[field]
    }

    /// Returns the value for the given field as a URL
    func url(forField field: String) -> URL? {
        return self[field]
    }
    
    /// Returns the value for the given field as an Int
    func int(forField field: String) -> Int? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Float
    func float(forField field: String) -> Float? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Double
    func double(forField field: String) -> Double? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Bool
    func bool(forField field: String) -> Bool? {
        return self[field]
    }
    
    func address(forField field: String) -> Address? {
        return self[field]
    }
    
    func subqueryResult(forField field: String) -> QueryResult<Record>? {
        return self[field]
    }
}

private extension Record {
    
    struct RecordCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? = nil
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
}
