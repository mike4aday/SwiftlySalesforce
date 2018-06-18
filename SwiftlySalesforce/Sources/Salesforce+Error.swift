//
//  Salesforce+Error.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation

public extension Salesforce {
	
	public enum Error: Swift.Error {
		case authenticationRequired
		case authenticationSessionFailed
		case resourceError(httpStatusCode: Int, message: String, errorCode: String?, fields: [String]?)
		case other(message: String?)
	}
}

extension Salesforce.Error: LocalizedError {
	
	public var errorDescription: String? {
		switch self {
		case .authenticationRequired:
			return NSLocalizedString("User authentication required", comment: "")
		case .authenticationSessionFailed:
			return NSLocalizedString("Failed to start user authentication session.", comment: "")
		default:
			return nil
		}
	}
}
