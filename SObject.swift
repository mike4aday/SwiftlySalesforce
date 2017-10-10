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
	/// - Parameter forField: name of the field whose value is to be retrieved
	/// - Returns: value retrieved for the given field
	public func value<T: Decodable>(forField key: String) throws -> T? {
		return try container.decodeIfPresent(T.self, forKey: SObjectCodingKey(stringValue: key)!)
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
