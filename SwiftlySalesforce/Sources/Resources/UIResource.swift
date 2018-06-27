//
//  UIResource.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/23/18.
//

import Foundation

internal enum UIResource {
	
	// Get default values to clone a record
	// See: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_record_defaults_clone.htm
	case defaultsForCloning(id: String, optionalFields: [String]?, recordTypeID: String?, version: String)
	
	// Get defaults to create a record
	// See: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_record_defaults_create.htm
	//case defaultsForCreating(type: String, formFactor: String?, optionalFields: [String]?, recordTypeID: String?, version: String)
}

extension UIResource: Resource {
	
	func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .defaultsForCloning(id, formFactor, optionalFields, recordTypeID, version):
			return try URLRequest(
				method: .get,
				baseURL: authorization.instanceURL.appendingPathComponent("/services/data/v\(version))/ui-api/record-defaults/clone/\(id)"),
				accessToken: authorization.accessToken,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue,
				queryParameters: {
					var params: [String: String] = [:]
					if let optionalFields = optionalFields { params["optionalFields"] = optionalFields.joined(separator: ",") }
					if let recordTypeID = recordTypeID { params["recordTypeId"] = recordTypeID }
					return params.count > 0 ? params : nil
				}(),
				body: nil,
				headers: nil
			)
		}
	}
}
