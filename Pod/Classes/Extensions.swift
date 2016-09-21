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
extension DataRequest {
	
	public func validateSalesforceResponse() -> Self {
		return  validate {
			(request, response, data) -> Request.ValidationResult in
			switch response.statusCode {
			case 401:
				return .failure(NSError(domain: NSURLErrorDomain, code: URLError.userAuthenticationRequired.rawValue, userInfo: nil))
			case 403:
				return .failure(NSError(domain: NSURLErrorDomain, code: URLError.noPermissionsToReadFile.rawValue, userInfo: nil))
			default:
				return .success
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
		return (self.code == URLError.userAuthenticationRequired.rawValue || self.code == URLError.noPermissionsToReadFile.rawValue)
			&& self.domain == NSURLErrorDomain
	}
}


// MARK: - Extension
extension URLComponents {
	public mutating func addQueryItems(_ queryItems: [String:String]) {
		guard queryItems.count > 0 else { return }
		if self.queryItems == nil {
			self.queryItems = [URLQueryItem]()
		}
		for name in queryItems.keys {
			self.queryItems?.append(URLQueryItem(name: name, value: queryItems[name]))
		}
	}
}


// MARK: - Extension
// Adapted from http://codingventures.com/articles/Dating-Swift/
extension DateFormatter {
	
	@nonobjc public static let SalesforceDateTime: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
		return formatter
	}()
	
	@nonobjc public static let SalesforceDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}


// MARK: - Extension
extension String {
	
	public var sentenceCapitalizedString: String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other	}
}


// MARK: - Extension
extension URL {
	
	/// Allows optional argument when creating a NSURL
	public init?(URLString: String?) {
		guard let s = URLString else {
			return nil
		}
		self.init(string: s)
	}
	
	/// Adapted from http://stackoverflow.com/questions/3997976/parse-nsurl-query-property
	/// - Parameter name: name of URL-encoded name/value pair in query string
	/// - Returns: First value (if more than one present in query string) as optional String
	public func valueForQueryItem(_ name: String) -> String? {
		let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
		let queryItems = urlComponents?.queryItems
		return queryItems?.filter({$0.name == name}).first?.value
	}
}

