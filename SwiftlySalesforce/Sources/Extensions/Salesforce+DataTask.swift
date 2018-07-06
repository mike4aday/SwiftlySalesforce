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
			return URLSession.shared.dataTask(.promise, with: req).validated(with: validator)
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

