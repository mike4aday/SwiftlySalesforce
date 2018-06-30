//
//  Salesforce+Custom.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//


import Foundation

public extension Salesforce {
	
	/// Use this method to call a Salesforce REST API endpoint that's not covered by the other methods.
	/// Note: baseURL and path should not both be nil
	/// - Parameter method: HTTP method
	/// - Parameter baseURL: Base URL to which the path parameter will be appended. If nil, then user's "instance URL" will be used
	/// - Parameter path: Absolute path to endpoint, relative to "baseURL" parameter or, if "baseURL" is nil, then relative to the user's "instance URL"
	/// - Parameter parameters: Dictionary of query string parameters
	/// - Parameter body: Data to be sent in the body of the request, e.g. JSON as Data in the body of a POST request
	/// - Parameter contentType: the MIME type of the request content; defaults to "application/json"
	/// - Parameter headers: Dictionary of custom HTTP header values
	/// - Returns: Promise of Data
	public func custom<T: Decodable>(
		method: String,
		url: URL? = nil,
		path: String? = nil,
		parameters: [String: Any?]? = nil,
		body: Data? = nil,
		contentType: String = URLRequest.MIMEType.json.rawValue,
		headers: [String: String]? = nil,
		validator: Validator? = nil,
		options: Options = []) -> Promise<T> {
		
		let params: [String: String]? = parameters?.mapValues { "\($0 ?? "")" }
		let resource = CustomResource(method: method, url: url, path: path, queryParameters: params, body: body, contentType: contentType, headers: headers)
		return dataTask(resource: resource, options: options, validator: validator)
	}
}
