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
	
	public func validateSalesforceResponse() -> Self {
		return validate {
			(request, response) -> Request.ValidationResult in
			switch response.statusCode {
			case 401:
				return .Failure(NSError(domain: NSURLErrorDomain, code: NSURLError.UserAuthenticationRequired.rawValue, userInfo: nil))
			case 403:
				return .Failure(NSError(domain: NSURLErrorDomain, code: NSURLError.NoPermissionsToReadFile.rawValue, userInfo: nil))
			default:
				return .Success
			}
		}.validate()
	}
}


// MARK: - Extension
extension NSError {
	
	/// Indicates whether or not the NSError instance represents an authentication error
	/// - Returns: true if the error indicates that Salesforce re/authentication is required
	public func isAuthenticationRequiredError() -> Bool {
		
		// When authentication is required, the Identity resource returns status code 403; other resources return 401
		return (self.code == NSURLError.UserAuthenticationRequired.rawValue || self.code == NSURLError.NoPermissionsToReadFile.rawValue)
			&& self.domain == NSURLErrorDomain
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


// MARK: - Extension
extension String {
	
	public var sentenceCapitalizedString: String {
		get {
			var s = String(self)
			s.replaceRange(s.startIndex...s.startIndex, with: String(s[s.startIndex]).capitalizedString)
			return s
		}
	}
}


// MARK: - Extension
extension NSURL {
	
	/// Allows optional argument when creating a NSURL
	public convenience init?(URLString: String?) {
		guard let s = URLString else {
			return nil
		}
		self.init(string: s)
	}
	
	/// Adapted from http://stackoverflow.com/questions/3997976/parse-nsurl-query-property
	/// - Parameter name: name of URL-encoded name/value pair in query string
	/// - Returns: First value (if more than one present in query string) as optional String
	public func valueForQueryItem(name: String) -> String? {
		let urlComponents = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
		let queryItems = urlComponents?.queryItems
		return queryItems?.filter({$0.name == name}).first?.value
	}
}

