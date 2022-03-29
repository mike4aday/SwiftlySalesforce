import Foundation

public typealias SObject = Record
public typealias SalesforceRecord = Record

public struct Record: Identifiable, Decodable {
    
    public let type: String
    public let id: String
    private let container: KeyedDecodingContainer<RecordCodingKey>
    
    public init(from decoder: Decoder) throws {
        
        self.container = try decoder.container(keyedBy: RecordCodingKey.self)
        
        struct Attributes: Decodable {
            var type: String
            var url: String?
        }
        
        let key = RecordCodingKey(stringValue: "attributes")!
        let attrs = try container.decode(Attributes.self, forKey: key)
        
        // SObject type
        self.type = attrs.type
        
        // Parse record ID
        if self.type.caseInsensitiveCompare("AggregateResult") == ComparisonResult.orderedSame {
            self.id = ""
        }
        else {
            guard let recordID = attrs.url?.components(separatedBy: "/").last, recordID.count == 15 || recordID.count == 18 else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Failed to decode record ID from url attribute.")
            }
            self.id = recordID
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
    
    /// Returns the value for the given field as a String
    public func string(forField field: String) -> String? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Date
    public func date(forField field: String) -> Date? {
        return self[field]
    }

    /// Returns the value for the given field as a URL
    public func url(forField field: String) -> URL? {
        return self[field]
    }
    
    /// Returns the value for the given field as an Int
    public func int(forField field: String) -> Int? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Float
    public func float(forField field: String) -> Float? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Double
    public func double(forField field: String) -> Double? {
        return self[field]
    }
    
    /// Returns the value for the given field as a Bool
    public func bool(forField field: String) -> Bool? {
        return self[field]
    }
    
    public func address(forField field: String) -> Address? {
        return self[field]
    }
    
    public func subqueryResult(forField field: String) -> QueryResult<Record>? {
        return self[field]
    }
}

extension Record {
    
    struct RecordCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? = nil
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
}
