//
//  SObject.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Represents a generic Salesforce object
public struct SObject {
	
	fileprivate var attributes: RecordAttributes
	fileprivate var container: KeyedDecodingContainer<SObjectCodingKey>

	/// Record ID
	public var id: String {
		return attributes.id
	}
	
	/// Type of object (e.g. Account, Lead, MyCustomObject__c)
	public var type: String {
		return attributes.type
	}
	
	/// Gets the value for a given field.
	/// - Parameter named: name of the field whose value is to be retrieved
	/// - Returns: value retrieved for the given field, or nil if the value is nil or not present.
	/// - Throws: Decoding error if the value cannot be decoded as type 'T'
	public func value<T: Decodable>(named: String) throws -> T? {
		return try container.decodeIfPresent(T.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
	
	public func string(named: String) throws -> String? {
		return try container.decodeIfPresent(String.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
	
	public func date(named: String) throws -> Date? {
		return try container.decodeIfPresent(Date.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
	
	public func url(named: String) throws -> URL? {
		return try container.decodeIfPresent(URL.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
	
	public func uint(named: String) throws -> UInt? {
		return try container.decodeIfPresent(UInt.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
	
	public func address(named: String) throws -> Address? {
		return try container.decode(Address.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
	
	/// Returns a subquery result. For example, the records returned by the query
	/// "SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account" will each have a field
	/// labeled "Contacts" that hold the results of the subquery in a struct of type QueryResult<SObject>.
	/// - Parameter named: name of the field containing the query result.
	/// - Returns: QueryResult<SObject> containing the subquery results decoded as SObjects
	public func subqueryResult(named: String) throws -> QueryResult<SObject>? {
		return try container.decodeIfPresent(QueryResult.self, forKey: SObjectCodingKey(stringValue: named)!)
	}
}

extension SObject: Decodable {
	
	fileprivate struct SObjectCodingKey: CodingKey {
	
		static let attributes = SObjectCodingKey(stringValue: "attributes")!

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
		self.container = try decoder.container(keyedBy: SObjectCodingKey.self)
		self.attributes = try container.decode(RecordAttributes.self, forKey: .attributes)
	}
}
