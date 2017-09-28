//
//  Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

public enum SalesforceError: Error {
	case resourceException(code: String, message: String, fields: [String]?)
	case resourceNotFound
	case serverFailure
	case unexpectedResponse(response: URLResponse?)
	case unsupportedURL(url: URL)
	case userAuthenticationRequired
}

public enum SerializationError: Error {
	case missing(String)
	case invalid(Any, message: String?)
}

public enum ApplicationError: Error {
	case invalidState(message: String)
	case invalidArgument(message: String)
}

enum KeychainError: Error {
	case readFailure(status: OSStatus)
	case writeFailure(status: OSStatus)
	case deleteFailure(status: OSStatus)
	case itemNotFound
}

extension SalesforceError: CustomDebugStringConvertible {
	
	public var debugDescription: String {
		switch self {
		case .userAuthenticationRequired:
			return "User authentication required"
		case let .unexpectedResponse(response):
			return "Unexpected response: \(String(describing: response))"
		case let .unsupportedURL(url):
			return "Unsupported URL: \(url.absoluteString)"
		case let .resourceException(code, message, fields):
			return "Resource exception. Code: \(code). Message: \(message). Fields: \(fields ?? [])"
		case .resourceNotFound:
			return "Resource not found"
		case .serverFailure:
			return "Server failure"
		}
	}
}
