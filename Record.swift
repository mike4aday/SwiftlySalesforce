//
//  Record.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Represents a generic Salesforce object record
public struct Record {
	
	fileprivate var attributes: RecordAttributes?
	fileprivate var container: KeyedDecodingContainer<RecordCodingKey>?
	fileprivate var mutableFields: [String: Codable?]
	
	
	
	/// Record ID
	public var id: String? {
		return attributes?.id
	}
	
	/// Type of object (e.g. Account, Lead, MyCustomObject__c)
	public var type: String? {
		return attributes?.type
	}
	
	/// Path to the record detail page in Salesforce
	public var path: String? {
		return attributes?.path
	}
	
	/// Subscript by field name; read only
	subscript<Value: Codable>(field: String) -> Value? {
		return value(forField: field)
	}
	
	/// Returns the value for the given field
	public func value<Value: Codable>(forField field: String) -> Value? {
		if mutableFields.keys.contains(field) {
			return mutableFields[field] as? Value
		}
		else {
			if let c = container, let key = RecordCodingKey(stringValue: field) {
				return try? c.decode(Value.self, forKey: key)
			}
			else {
				return nil
			}
		}
	}
	
	/// Returns the value for the given field as a String
	public func string(forField field: String) -> String? {
		return value(forField: field)
	}
	
	/// Returns the value for the given field as a Date
	public func date(forField field: String) -> Date? {
		return value(forField: field)
	}

	/// Returns the value for the given field as a URL
	public func url(forField field: String) -> URL? {
		return value(forField: field)
	}
	
	/// Returns the value for the given field as an Int
	public func int(forField field: String) -> Int? {
		return value(forField: field)
	}
	
	/// Returns the value for the given field as a Float
	public func float(forField field: String) -> Float? {
		return value(forField: field)
	}
	
	/// Returns the value for the given field as a Double
	public func double(forField field: String) -> Double? {
		return value(forField: field)
	}
	
	/// Returns the value for the given field as a Bool
	public func bool(forField field: String) -> Bool? {
		return value(forField: field)
	}
	
	/// Sets the value for the given field
	public mutating func setValue(_ value: Codable?, forField field: String) {
		mutableFields.updateValue(value, forKey: field)
	}
	
	public init(fields: [String: Codable?] = [String: Codable?]()) {
		self.mutableFields = fields 
	}
}

extension Record: Codable {
	
	fileprivate struct RecordCodingKey: CodingKey {
		
		var stringValue: String
		var intValue: Int? = nil
		
		init?(stringValue: String) {
			self.stringValue = stringValue
		}
		
		init?(intValue: Int) {
			return nil
		}
	}
	
	public init(from decoder: Decoder) throws {
		let cont = try decoder.container(keyedBy: RecordCodingKey.self)
		self.container = cont
		self.attributes = try cont.decodeIfPresent(RecordAttributes.self, forKey: RecordCodingKey(stringValue: "attributes")!)
		self.mutableFields = [String: Codable?]()
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: RecordCodingKey.self)
		for field in mutableFields {
			let codingKey = RecordCodingKey(stringValue: field.key)!
			if let value = mutableFields[field.key], value != nil {
				if let v = value as? Bool {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? Date {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? Double {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? Float {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? Int {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? String {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? UInt {
					try container.encode(v, forKey: codingKey)
				}
				else if let v = value as? URL {
					try container.encode(v, forKey: codingKey)
				}
				else {
					// Encode as a string if nothing else
					try container.encode(String(describing: value), forKey: codingKey)
				}
			}
			else {
				try container.encodeNil(forKey: codingKey)
			}
		}
	}
}

