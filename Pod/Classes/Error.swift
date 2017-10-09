//
//  Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

public enum SalesforceError: Error {
	case deserializationError(message: String?)
	case resourceException(code: String, message: String, fields: [String]?)
	case resourceNotFound
	case serverFailure
	case unexpectedResponse(response: URLResponse?)
	case unsupportedURL(url: URL)
	case userAuthenticationRequired
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
