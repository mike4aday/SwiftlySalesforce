//
//  Salesforce+Error.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation

public extension Salesforce {
	
	public struct ErrorInfo: Decodable {
		var message: String
		var errorCode: String?
		var fields: [String]?
	}
	
	public enum AuthorizationError: Error, LocalizedError {
		
		case sessionStartFailure
		case refreshTokenUnavailable
		
		public var errorDescription: String? {
			switch self {
			case .sessionStartFailure:
				return NSLocalizedString("Unable to start user authorization session.", comment: "")
			case .refreshTokenUnavailable:
				return NSLocalizedString("No refresh token available for OAuth2 'refresh token' flow.", comment: "")
			}
		}
	}
	
	public enum ErrorResponse: Error, LocalizedError {
		
		case unauthorized
		case error(httpStatusCode: Int, info: ErrorInfo)
		case other(httpStatusCode: Int)
		
		public var errorDescription: String? {
			switch self {
			case .unauthorized:
				return NSLocalizedString("User authentication required", comment: "")
			default:
				return nil
			}
		}
	}
}
