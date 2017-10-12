//
//  Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

public enum RequestError: Error {
	case resourceException(code: String, message: String, fields: [String]?)
	case resourceNotFound
	case serverFailure
	case userAuthenticationRequired
}

public enum ResponseError: Error {
	case invalidAuthorizationData
	case invalidImageData
	case invalidStringData
	case unhandledResponse(response: URLResponse)
	case unknown(message: String)
}

public enum ApplicationError: Error {
	case invalidState(message: String)
}

enum KeychainError: Error {
	case readFailure(status: OSStatus)
	case writeFailure(status: OSStatus)
	case deleteFailure(status: OSStatus)
	case itemNotFound
}
