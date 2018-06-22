//
//  Salesforce+Error.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation

public extension Salesforce {
	
	public enum Error: Swift.Error {
		case unauthorized
		case authenticationSessionFailed
		case refreshTokenUnavailable
		case resourceError(httpStatusCode: Int, errorCode: String?, message: String?, fields: [String]?)
		case invalidArgument(name: String, value: Any?, message: String?)
		case other(message: String?)
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
			return nil
		}
	}
}
