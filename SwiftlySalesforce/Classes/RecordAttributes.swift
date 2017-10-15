//
//  RecordAttributes.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

public struct RecordAttributes {
	var id: String
	var path: String
	var type: String
}

extension RecordAttributes: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case path = "url"
		case type
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let path = try container.decode(String.self, forKey: CodingKeys.path)
		let type = try container.decode(String.self, forKey: CodingKeys.type)
		
		guard let id = path.components(separatedBy: "/").last, id.count == 18 || id.count == 15 else {
			throw DecodingError.dataCorruptedError(forKey: .path, in: container, debugDescription: "Unable to parse record ID from path.")
		}
		
		self.id = id
		self.path = path
		self.type = type 
	}
}
