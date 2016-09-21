//
//  Error.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation


public enum SFError: Error {
	
	
	case invalidState(message: String)
	case invalidArgument(message: String)
	case authenticationFailure(message: String)
	case responseError(code: String, description: String)
	
	
	public static func errorFromURLEncodedString(_ URLEncodedString: String) -> Error? {
		
		// Create 'fake' URL with argument as query string
		guard let url = URL(string: "http://example.com?\(URLEncodedString)") else {
			return nil
		}
		
		guard let
			code = url.valueForQueryItem("error"),
			let desc = url.valueForQueryItem("error_description") else {
				
			return nil
		}
		
		return SFError.responseError(code: code, description: desc)
	}
}


// MARK: - Extension
extension SFError: CustomStringConvertible {

	public var description: String {
		switch self {
		case let .invalidState(message):
			return message
		case let .invalidArgument(message):
			return message
		case let .authenticationFailure(message):
			return message
		case let .responseError(code, description):
			return "\(code.replacingOccurrences(of: "_", with: " ").sentenceCapitalizedString): \(description.replacingOccurrences(of: "+", with: " "))"
		}
	}
}
