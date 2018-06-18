//
//  Promise+Validate.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation
import PromiseKit

internal extension Promise where T == DataResponse {
	
	internal func validated(with validator: DataResponseValidator? = nil) -> Promise<T> {
	
		if let validator = validator {
			return map(validator)
		}
		
		return map {
			guard let response = $0.response as? HTTPURLResponse else {
				return $0
			}
			switch response.statusCode {
			case 200..<300:
				return $0
			case 401:
				throw Salesforce.Error.authenticationRequired
			case let code:
				// Error - try to deseralize Salesforce-provided error information
				// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
				if let info = try? JSONDecoder().decode(ErrorInfo.self, from: $0.data) {
					throw Salesforce.Error.resourceError(httpStatusCode: code, message: info.message, errorCode: info.errorCode, fields: info.fields)
				}
				else {
					throw Salesforce.Error.resourceError(httpStatusCode: code, message: "Unknown resource error.", errorCode: nil, fields: nil)
				}
			}
		}
	}
}

fileprivate struct ErrorInfo: Decodable {
	var message: String
	var errorCode: String?
	var fields: [String]?
}
