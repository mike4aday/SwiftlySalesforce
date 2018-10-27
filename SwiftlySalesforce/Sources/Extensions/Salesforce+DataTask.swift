//
//  Salesforce+DataTask.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation
import PromiseKit

public extension Salesforce {
		
	public func dataTask(with request: URLRequestConvertible, options: Options = [], validator: Validator? = nil) -> Promise<DataResponse> {
		
		let go: (Authorization) throws -> Promise<DataResponse> = { auth in
			let req = try request.asURLRequest(with: auth)
			return Promise { seal in
				URLSession.shared.dataTask(with: req) { (data, response, error) in
					if let data = data, let response = response {
						seal.resolve((data, response), error)
					}
					else {
						seal.reject(Salesforce.Error.miscellaneous(message: "Unable to process response."))
					}
				}.resume()
			}.validated(with: validator)
		}
		
		return firstly { () -> Promise<DataResponse> in
			guard let auth = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			return try go(auth)
		}.recover { error -> Promise<DataResponse> in
			guard case Salesforce.Error.unauthorized = error else {
				throw error
			}
			return self.authorize(authenticateIfRequired: !options.contains(.dontAuthenticate)).then { auth in
				return try go(auth)
			}
		}
	}
	
	/// Makes an asynchronous call to Salesforce. Typically you won't need to call this method directly,
	/// but if you need to access a Salesforce endpoint that's not covered by one of the provided 'resources,' then
	/// you can create your own URLRequest and pass it as an argument to this method. If you don't specify a
	/// hostname for your URLRequest's URL, then the user's 'instance URL' will be used.
	/// - Parameter with: instance that conforms to URLRequestConvertible protocol, e.g. URLRequest
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Parameter validator: optional, custom validator to handle the result. Set to `nil` to use the default validator.
	/// - Returns: Promise of an instance that conforms to Decodable.
	/// - SeeAlso: URLRequest+URLRequestConvertible.swift
	public func dataTask<T: Decodable>(with request: URLRequestConvertible, options: Options = [], validator: Validator? = nil) -> Promise<T> {
		let q = DispatchQueue.global(qos: .userInitiated)
		return dataTask(with: request, options: options, validator: validator).map(on: q) { response in
			if T.self == Data.self {
				return response.data as! T
			}
			else {
				return try JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(T.self, from: response.data)
			}
		}
	}
}

