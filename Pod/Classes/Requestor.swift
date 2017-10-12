//
//  DataRequest.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

internal enum Requestor {
	case data
}
	
extension Requestor {
	
	internal typealias ResponseHandler = (Data?, URLResponse?, Error?) throws -> Data

	internal static let defaultResponseHandler: (Data?, URLResponse?, Error?) throws -> Data = {
		(data, response, error) throws in
		if let error = error {
			throw error
		}
		guard let response = response else {
			throw ResponseError.unknown(message: "Missing response.")
		}
		guard let httpResp = response as? HTTPURLResponse, let data = data else {
			// Not an HTTP response, or missing data
			throw ResponseError.unhandledResponse(response: response)
		}
		switch httpResp.statusCode {
		case 200..<300:
			return data
		case 401:
			throw RequestError.userAuthenticationRequired
		case 404:
			throw RequestError.resourceNotFound
		case 400..<500:
			// Try to form error from Salesforce's response
			// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
			if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]],
				let firstError = json?[0],
				let errorCode = firstError["errorCode"] as? String,
				let message = firstError["message"] as? String {
				throw RequestError.resourceException(code: errorCode, message: message, fields: firstError["fields"] as? [String])
			}
			else {
				throw ResponseError.unhandledResponse(response: response)
			}
		case 500:
			throw RequestError.serverFailure
		default:
			throw ResponseError.unhandledResponse(response: response)
		}
	}
	
	internal func request(resource: Resource, connectedApp: ConnectedApp, session: URLSession = URLSession.shared, responseHandler: @escaping ResponseHandler = Requestor.defaultResponseHandler) -> Promise<Data> {
		
		switch self {

		case .data:
			
			let go = {
				(req: URLRequest) -> Promise<Data> in
				return Promise {
					(fulfill, reject) -> () in
					let task: URLSessionDataTask = session.dataTask(with: req) {
						(data, resp, err) -> Void in
						do {
							fulfill(try responseHandler(data, resp, err))
						}
						catch {
							reject(error)
						}
					}
					task.resume()
				}
			}
			
			return Promise<OAuth2Result> {
				(fulfill, reject) -> () in
				if let auth = connectedApp.authData {
					fulfill(auth)
				}
				else {
					reject(RequestError.userAuthenticationRequired)
				}
			}.then {
				return try go(resource.asURLRequest(authData: $0))
			}.recover {
				(error: Error) -> Promise<Data> in
				if case RequestError.userAuthenticationRequired = error {
					return connectedApp.authorize().then {
						return try go(resource.asURLRequest(authData: $0))
					}
				}
				else {
					throw error
				}
			}
		}
	}
}
