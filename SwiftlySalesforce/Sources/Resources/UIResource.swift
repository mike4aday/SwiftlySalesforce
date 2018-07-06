//
//  UIResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum UIResource {
	
	// Get record data and metadata
	case records(
		recordIds: [String],
		childRelationships: [String]?,
		formFactor: String?,
		layoutTypes: [String]?,
		modes: [String]?,
		optionalFields: [String]?,
		pageSize: Int?,
		version: String
	)
	
	// Get default values for cloning a particular record
	case defaultsForCloning(
		recordId: String,
		formFactor: String?,
		optionalFields: [String]?,
		recordTypeId: String?,
		version: String
	)
	
	// Get defaults for creating a record of a particular type
	case defaultsForCreating(
		objectApiName: String,
		formFactor: String?,
		optionalFields: [String]?,
		recordTypeId: String?,
		version: String
	)
}

extension UIResource: URLRequestConvertible {
	
	func asURLRequest(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .records(ids, childRelationships, formFactor, layoutTypes, modes, optionalFields, pageSize, version):
			let path = "/services/data/v\(version)/ui-api/record-ui/\(ids.joined(separator: ","))"
			var queryItems = [URLQueryItem]()
			if let childRelationships = childRelationships?.joined(separator: ",") {
				queryItems.append(URLQueryItem(name: "childRelationships", value: childRelationships))
			}
			if let formFactor = formFactor {
				queryItems.append(URLQueryItem(name: "formFactor", value: formFactor))
			}
			if let layoutTypes = layoutTypes?.joined(separator: ",") {
				queryItems.append(URLQueryItem(name: "layoutTypes", value: layoutTypes))
			}
			if let modes = modes?.joined(separator: ",") {
				queryItems.append(URLQueryItem(name: "modes", value: modes))
			}
			if let optionalFields = optionalFields?.joined(separator: ",") {
				queryItems.append(URLQueryItem(name: "optionalFields", value: optionalFields))
			}
			if let pageSize = pageSize {
				queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
			}
			return try URLRequest(path: path, authorization: authorization, queryItems: queryItems)
			
		case let .defaultsForCloning(id, formFactor, optionalFields, recordTypeId, version):
			let path = "/services/data/v\(version)/ui-api/record-defaults/clone/\(id)"
			var queryItems = [URLQueryItem]()
			if let formFactor = formFactor {
				queryItems.append(URLQueryItem(name: "formFactor", value: formFactor))
			}
			if let optionalFields = optionalFields?.joined(separator: ",") {
				queryItems.append(URLQueryItem(name: "optionalFields", value: optionalFields))
			}
			if let recordTypeId = recordTypeId {
				queryItems.append(URLQueryItem(name: "recordTypeId", value: recordTypeId))
			}
			return try URLRequest(path: path, authorization: authorization, queryItems: queryItems)
			
		case let .defaultsForCreating(objectApiName, formFactor, optionalFields, recordTypeId, version):
			let path = "/services/data/v\(version)/ui-api/record-defaults/create/\(objectApiName)"
			var queryItems = [URLQueryItem]()
			if let formFactor = formFactor {
				queryItems.append(URLQueryItem(name: "formFactor", value: formFactor))
			}
			if let optionalFields = optionalFields?.joined(separator: ",") {
				queryItems.append(URLQueryItem(name: "optionalFields", value: optionalFields))
			}
			if let recordTypeId = recordTypeId {
				queryItems.append(URLQueryItem(name: "recordTypeId", value: recordTypeId))
			}
			return try URLRequest(path: path, authorization: authorization, queryItems: queryItems)
		}
	}
}
