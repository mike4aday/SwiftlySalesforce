//
//  Extensions.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


// MARK: - Extension
extension Request {
	
	public func salesforceResponse(completionHandler: Response<AnyObject, NSError> -> Void) -> Self {
		return response(responseSerializer: Request.salesforceResponseSerializer(), completionHandler: completionHandler)
	}
	
	public static func salesforceResponseSerializer() -> ResponseSerializer<AnyObject, NSError> {
		
		return ResponseSerializer {
			
			request, response, data, error in
			
			guard response?.statusCode < 400 else {
				return .Failure(NSError.errorForSalesforceResponse(request: request, response: response, data: data, error: error))
			}
			return JSONResponseSerializer().serializeResponse(request, response, data, error)
		}
	}
}


// MARK: - Extension
extension NSError {
	
	/// Crates an NSError object from a Salesforce API error response
	/// - Returns: NSError object
	static func errorForSalesforceResponse(request request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> NSError {
		
		// Default result
		var result: (domain: String, code: Int, userInfo: [NSObject: AnyObject]) = (NSURLErrorDomain, NSURLError.Unknown.rawValue, [:])
		if let failingURL = request?.URL {
			result.userInfo[NSURLErrorFailingURLErrorKey] = failingURL
		}
		
		// Parse JSON for message and string code from Salesforce
		let serialization = Request.JSONResponseSerializer().serializeResponse(request, response, data, nil) // Ignoring any parsing error for now
		switch serialization {
		case .Success(let json):
			if let msg = json[0]?["message"] as? String {
				var reason = msg
				if let salesforceErrorCode = json[0]?["errorCode"] as? String {
					reason += " (\(salesforceErrorCode))"
				}
				result.userInfo[NSLocalizedFailureReasonErrorKey] = reason
			}
		case .Failure(let serializationError):
			debugPrint(serializationError)
		}
		
		let map: [Int: NSURLError] = [400: .BadURL, 401: .UserAuthenticationRequired, 403: .NoPermissionsToReadFile, 404: .FileDoesNotExist, 405: .BadURL, 415: .BadURL]
		if let statusCode = response?.statusCode, let errorCode = map[statusCode] {
			result.code = errorCode.rawValue
		}
		
		return NSError(domain: result.domain, code: result.code, userInfo: result.userInfo)
	}
	
	/// Indicates whether or not the NSError instance represents an authentication error
	/// - Returns: true if the error indicates that Salesforce authentication is required
	public func isAuthenticationRequiredError() -> Bool {
		return self.code == NSURLError.UserAuthenticationRequired.rawValue
	}
}


// MARK: - Extension
extension NSURLComponents {
	public func addQueryItems(queryItems: [String:String]) {
		guard queryItems.count > 0 else { return }
		if self.queryItems == nil {
			self.queryItems = [NSURLQueryItem]()
		}
		for name in queryItems.keys {
			self.queryItems?.append(NSURLQueryItem(name: name, value: queryItems[name]))
		}
	}
}

// MARK: - Extension
// Adapted from http://codingventures.com/articles/Dating-Swift/
extension NSDateFormatter {
	
	@nonobjc public static let SalesforceDateTime: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		formatter.timeZone = NSTimeZone()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
		return formatter
	}()
	
	@nonobjc public static let SalesforceDate: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		formatter.timeZone = NSTimeZone()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}