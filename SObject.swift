//
//  SObject.swift
//  Pods-SwiftlySalesforce_Example
//
//  Created by Michael Epstein on 10/6/17.
//

import Foundation

public struct SObject {
	
	public var id: String
	public var type: String
	
	fileprivate var container: KeyedDecodingContainer<SObjectCodingKey>
	
	public func field<T: Decodable>(named key: String) throws -> T? {
		return try container.decodeIfPresent(T.self, forKey: SObjectCodingKey(stringValue: key)!)
	}
}

extension SObject: Decodable {
	
	struct SObjectCodingKey: CodingKey {
		
		var stringValue: String
		var intValue: Int?
		
		init?(stringValue: String) {
			self.stringValue = stringValue
		}
		
		init?(intValue: Int) {
			return nil
		}
		
		static let attributes = SObjectCodingKey(stringValue: "attributes")!
	}
	
	enum AttributeCodingKeys: String, CodingKey {
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
