//
//  Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation


public enum Error: ErrorType {
	
	
	case InvalidState(message: String)
	case InvalidArgument(message: String)
	case AuthenticationFailure(message: String)
	case ResponseError(code: String, description: String)
	
	
	public static func errorFromURLEncodedString(URLEncodedString: String) -> Error? {
		
		// Create 'fake' URL with argument as query string
		guard let url = NSURL(string: "http://example.com?\(URLEncodedString)") else {
			return nil
		}
		
		guard let
			code = url.valueForQueryItem("error"),
			desc = url.valueForQueryItem("error_description") else {
				
			return nil
		}
		
		return Error.ResponseError(code: code, description: desc)
	}
}


// MARK: - Extension
extension Error: CustomStringConvertible {

	public var description: String {
		switch self {
		case let .InvalidState(message):
			return message
		case let .InvalidArgument(message):
			return message
		case let .AuthenticationFailure(message):
			return message
		case let .ResponseError(code, description):
			return "\(code.stringByReplacingOccurrencesOfString("_", withString: " ").sentenceCapitalizedString): \(description.stringByReplacingOccurrencesOfString("+", withString: " "))"
		}
	}
}