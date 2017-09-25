//
//  DataRequest.swift
//  Alamofire
//
//  Created by Michael Epstein on 9/25/17.
//

import Foundation

internal struct DataRequestor {
	
	internal typealias ResponseHandler = (Data?, URLResponse?, Error?) throws -> Data

	internal private(set) var connectedApp: ConnectedApp
	internal private(set) var session: URLSession
	
	internal init(connectedApp: ConnectedApp, session: URLSession = URLSession.shared) {
		self.connectedApp = connectedApp
		self.session = session
	}
	
	internal static let defaultResponseHandler: (Data?, URLResponse?, Error?) throws -> Data = {
		(data, response, error) throws in
		if let error = error {
			throw error
		}
		guard let resp = response, let httpResp = resp as? HTTPURLResponse, let data = data else {
			throw  SalesforceError.unexpectedResponse(response: response)
		}
		switch httpResp.statusCode {
		case 200..<300:
			return data
		case 401:
			throw SalesforceError.userAuthenticationRequired
		case 400..<500:
			// Try to form error from Salesforce's response
			// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
			if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]],
				let firstError = json?[0],
				let errorCode = firstError["errorCode"] as? String,
				let message = firstError["message"] as? String {
				throw SalesforceError.resourceException(code: errorCode, message: message, fields: firstError["fields"] as? [String])
			}
			else {
				throw SalesforceError.unexpectedResponse(response: response)
			}
		case 500:
			throw SalesforceError.serverFailure
		default:
			throw SalesforceError.unexpectedResponse(response: response)
		}
	}
	
	internal func request(resource: Resource, responseHandler: @escaping ResponseHandler = DataRequestor.defaultResponseHandler) -> Promise<Data> {
		
		let _request = {
			(req: URLRequest) -> Promise<Data> in
			return Promise {
				(fulfill, reject) -> () in
				let task: URLSessionDataTask = URLSession.shared.dataTask(with: req) {
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
				reject(SalesforceError.userAuthenticationRequired)
			}
		}.then {
			return try _request(resource.asURLRequest(authData: $0))
		}.recover {
			(error: Error) -> Promise<Data> in
			if case SalesforceError.userAuthenticationRequired = error {
				return self.connectedApp.authorize().then {
					return try _request(resource.asURLRequest(authData: $0))
				}
			}
			else {
				throw error
			}
		}
	}
}
