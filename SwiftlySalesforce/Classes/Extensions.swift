//
//  Extensions.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

public extension DateFormatter {
	
	// Adapted from http://codingventures.com/articles/Dating-Swift/

	public static let salesforceDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
		return formatter
	}()
	
	public static let salesforceDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}

public extension Dictionary {
	
	/// Creates a dictionary from an array of items.
	/// - Parameter items: array whose elements will become values in the dictionary
	/// - Parameter key: function that returns a key for the given item
	public init(items: [Value], key: (Value) -> Key) {
		self.init()
		for item in items {
			self[key(item)] = item
		}
	}
}

public extension JSONDecoder {
	
	convenience init(dateFormatter: DateFormatter) {
		self.init()
		self.dateDecodingStrategy = .formatted(DateFormatter.salesforceDateTimeFormatter)
	}
}

public extension Promise where T == Data {

	/// Convert Data to UIImage. Borrowed from PromiseKit - see:
	/// https://github.com/PromiseKit/Foundation/blob/06ba5746d8bdfed3dde17679ef20d37922de867f/Sources/URLDataPromise.swift
	public func asImage(on queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)) -> Promise<UIImage> {
		return then(on: queue) {
			data -> UIImage in
			guard let img = UIImage(data: data), let cgimg = img.cgImage else {
				throw ResponseError.invalidImageData
			}
			// This way of decoding the image limits main thread impact when displaying the image
			return UIImage(cgImage: cgimg, scale: img.scale, orientation: img.imageOrientation)
		}
	}
	
	/// Convert Data to String
	public func asString() -> Promise<String> {
		return then {
			data -> String in
			guard let str = String(bytes: data, encoding: .utf8) else {
				throw ResponseError.invalidStringData
			}
			return str
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
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
	}
	
	init?(url: URL, parameters: [String: Any]?) {
		self.init(url: url, resolvingAgainstBaseURL: false)
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
	}
}
