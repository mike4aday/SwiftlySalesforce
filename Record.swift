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
	fileprivate var mutableFields: [String: Any?]
	
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
	
	subscript<T: Decodable>(fieldName: String) -> T? {
		
		get {
			if mutableFields.keys.contains(fieldName) {
				return mutableFields[fieldName] as? T
			}
			else {
				if let c = container, let key = RecordCodingKey(stringValue: fieldName) {
					return try? c.decode(T.self, forKey: key)
				}
				else {
					return nil
				}
			}
		}
		
		set {
			mutableFields[fieldName] = newValue
		}
	}
	
	init(fields: [String: Any?] = [String: Any?]()) {
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
		self.attributes = try cont.decode(RecordAttributes.self, forKey: RecordCodingKey(stringValue: "attributes")!)
		self.mutableFields = [String: Any?]()
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: RecordCodingKey.self)
		for field in mutableFields {
			try container.encode(mutableFields[field.key], forKey: RecordCodingKey(stringValue: field.key)!)
		}
	}
}

