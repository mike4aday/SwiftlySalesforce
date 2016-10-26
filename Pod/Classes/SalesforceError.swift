//
//  SalesforceError.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

public enum SalesforceError: Error {
	case userAuthenticationRequired
	case invalidity(message: String)
	case unsupportedURL(url: URL)
	case responseFailure(code: String, message: String, fields: [String]?)
	case jsonDeserializationFailure(elementName: String?, json: Any)
	case serverFailure
}

extension SalesforceError: CustomDebugStringConvertible {
	
	public var debugDescription: String {
		switch self {
		case .userAuthenticationRequired:
			return "User authentication required"
		case let .invalidity(message):
			return "Invalid: \(message)"
		case let .unsupportedURL(url):
			return "Unsupported URL: \(url.absoluteString)"
		case let .responseFailure(code, message, fields):
			return "Salesforce response failure. Code: \(code). Message: \(message). Fields: \(fields ?? [])"
		default:
			return "\(self)"
		}
	}
}
