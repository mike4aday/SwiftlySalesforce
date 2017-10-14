//
//  SObject.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Represents a generic Salesforce object
public struct SObject {
	
	/// Record ID
	public var id: String
	
	/// Type of object (e.g. Account, Lead, MyCustomObject__c)
	public var type: String
	
	fileprivate var container: KeyedDecodingContainer<SObjectCodingKey>
	
	/// Gets the value for a given field.
	/// - Parameter named: name of the field whose value is to be retrieved
	/// - Returns: value retrieved for the given field
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
	
	fileprivate enum AttributeCodingKeys: String, CodingKey {
		case type, url
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: SObjectCodingKey.self)
		let attributes = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: SObjectCodingKey.attributes)
		let type = try attributes.decode(String.self, forKey: .type)
		let path = try attributes.decode(String.self, forKey: .url)
		guard let id = path.components(separatedBy: "/").last, id.characters.count == 15 || id.characters.count == 18 else {
			throw DecodingError.dataCorruptedError(forKey: AttributeCodingKeys.url, in: attributes, debugDescription: "Unable to parse ID from URL attribute.")
		}
		self.id = id
		self.type = type
		self.container = container
	}
}
