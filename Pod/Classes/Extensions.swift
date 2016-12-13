//
//  Extensions.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

extension URL {
	
	/// Allows optional argument when creating a URL
	public init?(string: String?) {
		guard let s = string else {
			return nil
		}
		self.init(string: s)
	}
	
	/// Adapted from http://stackoverflow.com/questions/3997976/parse-nsurl-query-property
	/// - Parameter name: name of URL-encoded name/value pair in query string
	/// - Returns: First value (if more than one present in query string) as optional String
	public func value(forQueryItem name: String) -> String? {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
			return nil
		}
		return queryItems.filter({$0.name == name}).first?.value
	}
}

extension URLComponents {
	
	init?(string: String, parameters: [String: Any]?) {
		self.init(string: string)
		if let params = parameters {
			var queryItems = [URLQueryItem]()
			for param in params {
				queryItems.append(URLQueryItem(name: param.key, value: "\(param.value)"))
			}
			self.queryItems = queryItems
		}
	}
}

extension DateFormatter {
	
	// Adapted from http://codingventures.com/articles/Dating-Swift/

	@nonobjc public static let salesforceDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
		return formatter
	}()
	
	@nonobjc public static let salesforceDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}

extension Dictionary {
	
	public func dateValue(forKey: Key, formatter: DateFormatter = DateFormatter.salesforceDateTimeFormatter) -> Date? {
		if let dateValue = self[forKey] as? Date {
			return dateValue
		}
		else if let stringValue = self[forKey] as? String {
			return formatter.date(from: stringValue)
		}
		else {
			return nil
		}
	}
}

public extension UIApplicationDelegate where Self: LoginDelegate {
	
	public func configureSalesforce(consumerKey: String, redirectURL: URL, version: String = Salesforce.defaultVersion) {
		let config = AuthManager.Configuration(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: self)
		salesforce.authManager.configuration = config
		salesforce.version = version
	}
}

/// Transform a collection into a dictionary
/// From: https://gist.github.com/ijoshsmith/0c966b1752b9a5722e23
public extension Collection {
	
	func asDictionary<K, V>(transform:(_ element: Iterator.Element) -> [K : V]) -> [K : V] {
		var dictionary = [K : V]()
		self.forEach { element in
			for (key, value) in transform(element) {
				dictionary[key] = value
			}
		}
		return dictionary
	}
}
