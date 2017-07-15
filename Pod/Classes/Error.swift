//
//  Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

public enum SalesforceError: Error {
	case resourceException(code: String, message: String, fields: [String]?)
	case serverFailure
	case userAuthenticationRequired
	case unsupportedURL(url: URL)
}

public enum SerializationError: Error {
	case missing(String)
	case invalid(Any, message: String?)
}

public enum ApplicationError: Error {
	case invalidState(message: String)
	case invalidArgument(message: String)
}

extension SalesforceError: CustomDebugStringConvertible {
	
	public var debugDescription: String {
		switch self {
		case .userAuthenticationRequired:
			return "User authentication required"
		case let .unsupportedURL(url):
			return "Unsupported URL: \(url.absoluteString)"
		case let .resourceException(code, message, fields):
			return "Salesforce response failure. Code: \(code). Message: \(message). Fields: \(fields ?? [])"
		case .serverFailure:
			return "Server failure"
		}
	}
}
