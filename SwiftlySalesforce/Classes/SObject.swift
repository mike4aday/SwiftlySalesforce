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
	fileprivate var mutableFields = [String: Any?]()

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
		return try getValue(named: named, asType: T.self)
	}
	
	/// Gets the value of a field as a String
	public func string(named: String) throws -> String? {
		return try getValue(named: named, asType: String.self)
	}
	
	/// Gets the value of a field as a Date
	public func date(named: String) throws -> Date? {
		return try getValue(named: named, asType: Date.self)
	}
	
	/// Gets the value of a field as a URL
	public func url(named: String) throws -> URL? {
		return try getValue(named: named, asType: URL.self)
	}
	
	/// Gets the value of a field as an unsigned integer
	public func uint(named: String) throws -> UInt? {
		return try getValue(named: named, asType: UInt.self)
	}
	
	/// Gets the value of a field as an Address
	public func address(named: String) throws -> Address? {
		return try getValue(named: named, asType: Address.self)
	}
	
	/// Returns a subquery result. For example, the records returned by the query
	/// "SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account" will each have a field
	/// labeled "Contacts" that hold the results of the subquery in a struct of type QueryResult<SObject>.
	/// - Parameter named: name of the field containing the query result.
	/// - Returns: QueryResult<SObject> containing the subquery results decoded as SObjects
	public func subqueryResult(named: String) throws -> QueryResult<SObject>? {
		return try getValue(named: named, asType: QueryResult<SObject>.self)
	}
	
	fileprivate func getValue<T: Decodable>(named: String, asType: T.Type) throws -> T? {
		if mutableFields.keys.contains(named) {
			return mutableFields[named] as? T
		}
		else {
			return try container.decodeIfPresent(T.self, forKey: SObjectCodingKey(stringValue: named)!)
		}
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
