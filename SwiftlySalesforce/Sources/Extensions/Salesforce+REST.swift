//
//  Salesforce+REST.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation
import PromiseKit

public extension Salesforce {
	
	// MARK: - Image methods
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. images at Account.PhotoUrl, Contact.PhotoUrl, or Lead.PhotoUrl.
	/// - Parameter path: path relative to the user's instance URL
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of an image 
	public func fetchImage(path: String, options: Options = []) -> Promise<UIImage> {
		let resource = RESTResource.smallFile(url: nil, path: path, accept: "image/*")
		let bgq = DispatchQueue.global(qos: .userInitiated)
		return dataTask(with: resource, options: options).compactMap(on: bgq) { (result: DataResponse) -> UIImage? in
			UIImage(data: result.data)
		}
	}
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. User.SmallPhotoUrl or User.FullPhotoUrl.
	/// - Parameter url: URL to the image to be retrieved
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of an image
	public func fetchImage(url: URL, options: Options = []) -> Promise<UIImage> {
		let resource = RESTResource.smallFile(url: url, path: nil, accept: "image/*")
		let bgq = DispatchQueue.global(qos: .userInitiated)
		return dataTask(with: resource, options: options).compactMap(on: bgq) { (result: DataResponse) -> UIImage? in
			UIImage(data: result.data)
		}
	}
	
	// MARK: - Miscellaneous

	/// Asynchronously requests information about the current user
	/// See https://help.salesforce.com/articleView?id=remoteaccess_using_openid.htm&type=0
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	public func identity(options: Options = []) -> Promise<Identity> {
		let resource = RESTResource.identity(version: configuration.version)
		let validator: Validator = {
			if let httpResp = $0.response as? HTTPURLResponse, httpResp.statusCode == 403 {
				throw Salesforce.Error.unauthorized
			}
			return try Promise.defaultValidator($0)
		}
		return dataTask(with: resource, options: options, validator: validator)
	}
	
	/// Asynchronously retrieves information about the Salesforce organization ("org")
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_organization.htm
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	public func organization(options: Options = []) -> Promise<Organization> {
		return identity(options: options).then {
			self.retrieve(type: "Organization", id: $0.orgID)
		}
	}
	
	/// Asynchronously retrieves information about org limits
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of a dictionary of Limits, keyed by limit name
	public func limits(options: Options = []) -> Promise<[String:Limit]> {
		let resource = RESTResource.limits(version: configuration.version)
		return dataTask(with: resource, options: options)
	}
	
	// MARK: - Apex web services
	
	/// Asynchronously calls an Apex method exposed as a REST endpoint.
	/// See https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST
	/// - Parameter method: HTTP method
	/// - Parameter path: String that gets appended to instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of query string parameters
	/// - Parameter body: Data to be sent in the body of the request, e.g. JSON as Data in the body of a POST request
	/// - Parameter headers: Dictionary of HTTP header values
	/// - Parameter options: if you want to defer login, set to [.dontAuthenticate]
	/// - Returns: Promise of Decodable type
	public func apex<T: Decodable>(
		method: String = "GET",
		path: String,
		parameters: [String: String]? = nil,
		body: Data? = nil,
		headers: [String: String]? = nil,
		options: Options = []) -> Promise<T> {
		
		let resource = RESTResource.apex(method: method, path: path, parameters: parameters, body: body, headers: nil)
		return dataTask(with: resource, options: options)
	}
}
