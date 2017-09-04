//
//  Extensions.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Alamofire

public extension DateFormatter {
	
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

public extension DataRequest {
	
	/// Adds a handler to be called once the request has finished.
	/// Borrowed from https://github.com/PromiseKit/Alamofire-/blob/master/Sources/Alamofire+Promise.swift
	public func response() -> Promise<(URLRequest, HTTPURLResponse, Data)> {
		return Promise { fulfill, reject in
			response(queue: nil) { rsp in
				if let error = rsp.error {
					reject(error)
				} else if let a = rsp.request, let b = rsp.response, let c = rsp.data {
					fulfill((a, b, c))
				} else {
					reject(SerializationError.invalid(rsp, message: "Invalid response"))
				}
			}
		}
	}
	
	/// Adds a handler to be called once the request has finished.
	/// Borrowed from https://github.com/PromiseKit/Alamofire-/blob/master/Sources/Alamofire+Promise.swift
	public func responseData() -> Promise<Data> {
		return Promise { fulfill, reject in
			responseData(queue: nil) { response in
				switch response.result {
				case .success(let value):
					fulfill(value)
				case .failure(let error):
					reject(error)
				}
			}
		}
	}
	
	/// Adds a handler to be called once the request has finished.
	public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<Any> {
		return Promise { fulfill, reject in
			responseJSON(queue: nil, options: options, completionHandler: { response in
				switch response.result {
				case .success(let value):
					fulfill(value)
				case .failure(let error):
					reject(error)
				}
			})
		}
	}
	
	/// Adds a handler to be called once the request has finished and the resulting JSON is rooted at a dictionary.
	/// Borrowed from https://github.com/PromiseKit/Alamofire-/blob/master/Sources/Alamofire+Promise.swift
	public func responseJSONDictionary(options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<[String: Any]> {
		return Promise { fulfill, reject in
			responseJSON(queue: nil, options: options, completionHandler: { response in
				switch response.result {
				case .success(let value):
					if let value = value as? [String: Any] {
						fulfill(value)
					} else {
						reject(SerializationError.invalid(value, message: "Invalid JSON dictionary response"))
					}
				case .failure(let error):
					reject(error)
				}
			})
		}
	}

	public func validateSalesforceResponse() -> Self {
		return validate {
			(request, response, data) -> Request.ValidationResult in
			switch response.statusCode {
			case 401:
				return .failure(SalesforceError.userAuthenticationRequired)
			case 400..<500:
				// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
				if let data = data,
					let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]],
					let firstError = json?[0],
					let errorCode = firstError["errorCode"] as? String,
					let message = firstError["message"] as? String {
					return .failure(SalesforceError.resourceException(code: errorCode, message: message, fields: firstError["fields"] as? [String]))
				}
				else {
					return .failure(SalesforceError.resourceException(code: "UNKNOWN_ERROR", message: "Unknown error. HTTP response status code: \(response.statusCode)", fields: nil))
				}
			case 500:
				return .failure(SalesforceError.serverFailure)
			default:
				return .success // The next .validate() call will catch other errors not caught above
			}
		}.validate()
	}
}

/// Extension for JSON dictionaries acting as Salesforce records
public extension Dictionary where Key == String, Value == Any {
	
	var attributes: (id: String, type: String, path: String)? {
		guard let attrs = self["attributes"] as? [String: Any],
			let type = attrs["type"] as? String,
			let path = attrs["url"] as? String,
			let id = path.components(separatedBy: "/").last, id.characters.count == 15 || id.characters.count == 18 else {
				return nil
		}
		return (id, type, path)
	}
	
	var id: String? {
		return attributes?.id
	}
	
	var type: String? {
		return attributes?.type
	}
	
	var name: String? {
		return self["Name"] as? String
	}
	
	var lastModifiedDate: Date? {
		return self.date(for: "LastModifiedDate")
	}
	
	var createdDate: Date? {
		return self.date(for: "CreatedDate")
	}
	
	public func date(for key: Key, formatter: DateFormatter = DateFormatter.salesforceDateTimeFormatter) -> Date? {
		if let dateValue = self[key] as? Date {
			return dateValue
		}
		else if let stringValue = self[key] as? String {
			return formatter.date(from: stringValue)
		}
		else {
			return nil
		}
	}
	
	public func address(for key: Key) -> Address? {
		if let json = self[key] as? [String: Any] {
			return Address(json: json)
		}
		else {
			return nil
		}
	}
	
	public func url(for key: Key) -> URL? {
		if let url = self[key] as? URL {
			return url
		}
		else {
			return URL(string: self[key] as? String)
		}
	}
}

public extension URL {
	
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

public extension URLComponents {
	
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
