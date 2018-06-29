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
	
	case defaultsForCloning(
		recordId: String,
		formFactor: String?,
		optionalFields: [String]?,
		recordTypeId: String?,
		version: String
	)
	
	case defaultsForCreating(
		objectApiName: String,
		formFactor: String?,
		optionalFields: [String]?,
		recordTypeId: String?,
		version: String
	)
	
	case picklistValues(
		objectApiName: String,
		recordTypeId: String,
		version: String
	)
}

extension UIResource: Resource {
	
	func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .records(ids, childRelationships, formFactor, layoutTypes, modes, optionalFields, pageSize, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/ui-api/record-ui/\(ids.joined(separator: ","))"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: {
					var params: [String: String] = [:]
					if let childRelationships = childRelationships { params["childRelationships"] = childRelationships.joined(separator: ",") }
					if let formFactor = formFactor { params["formFactor"] = formFactor }
					if let layoutTypes = layoutTypes { params["layoutTypes"] = layoutTypes.joined(separator: ",") }
					if let modes = modes { params["modes"] = modes.joined(separator: ",") }
					if let optionalFields = optionalFields { params["optionalFields"] = optionalFields.joined(separator: ",") }
					if let pageSize = pageSize { params["pageSize"] = "\(pageSize)" }
					return params.count > 0 ? params : nil
			}(),
				body: nil,
				headers: nil
			)
			
		case let .defaultsForCloning(id, formFactor, optionalFields, recordTypeID, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/ui-api/record-defaults/clone/\(id)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: {
					var params: [String: String] = [:]
					if let formFactor = formFactor { params["formFactor"] = formFactor }
					if let optionalFields = optionalFields { params["optionalFields"] = optionalFields.joined(separator: ",") }
					if let recordTypeID = recordTypeID { params["recordTypeId"] = recordTypeID }
					return params.count > 0 ? params : nil
			}(),
				body: nil,
				headers: nil
			)
			
		case let .defaultsForCreating(objectApiName, formFactor, optionalFields, recordTypeId, version):
			 return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/ui-api/record-defaults/create/\(objectApiName)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: {
					var params: [String: String] = [:]
					if let formFactor = formFactor { params["formFactor"] = formFactor }
					if let optionalFields = optionalFields { params["optionalFields"] = optionalFields.joined(separator: ",") }
					if let recordTypeId = recordTypeId { params["recordTypeId"] = recordTypeId }
					return params.count > 0 ? params : nil
			}(),
				body: nil,
				headers: nil
			)
			
		case let .picklistValues(objectApiName, recordTypeId, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version)/ui-api/object-info/\(objectApiName)/picklist-values/\(recordTypeId)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: nil,
				body: nil,
				headers: nil
			)
		}
	}
}
