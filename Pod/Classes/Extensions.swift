//
//  Extensions.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

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

public extension Promise where T == Data {
	
	/// Decode the HTTP response as a JSON dictionary
	public func asJSON() -> Promise<[String: Any]> {
		return then {
			(data) -> [String: Any] in
			guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let dict = json as? [String: Any] else {
				throw SerializationError.invalid(data, message: nil)
			}
			return dict
		}
	}
	
	/// Convert Data to UIImage. Borrowed from PromiseKit - see:
	/// https://github.com/PromiseKit/Foundation/blob/06ba5746d8bdfed3dde17679ef20d37922de867f/Sources/URLDataPromise.swift
	public func asImage(on queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)) -> Promise<UIImage> {
		return then(on: queue) {
			data -> UIImage in
			guard let img = UIImage(data: data), let cgimg = img.cgImage else {
				throw SerializationError.invalid(String(describing: data), message: "Unable to serialize image")
			}
			// This way of decoding the image limits main thread impact when displaying the image
			return UIImage(cgImage: cgimg, scale: img.scale, orientation: img.imageOrientation)
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
