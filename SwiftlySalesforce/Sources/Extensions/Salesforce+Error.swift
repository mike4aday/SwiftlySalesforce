//
//  Salesforce+Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension Salesforce {
	
	public enum Error: Swift.Error {
		case unauthorized
		case authenticationSessionFailed
		case badRequest(message: String?)
		case invalidArgument(name: String, value: Any?, message: String?)
		case refreshTokenUnavailable
		case resourceError(httpStatusCode: Int, errorCode: String?, message: String?, fields: [String]?)
		case miscellaneous(message: String?)
	}
}

extension Salesforce.Error: LocalizedError {
	
	public var errorDescription: String? {
		switch self {
		case .unauthorized:
			return NSLocalizedString("User authentication required", comment: "")
		case .authenticationSessionFailed:
			return NSLocalizedString("Failed to start user authentication session.", comment: "")
		default:
			return "\(self)"
		}
	}
}
