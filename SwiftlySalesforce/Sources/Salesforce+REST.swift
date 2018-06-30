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
	/// - Returns: Promise of an image
	public func fetchImage(path: String, options: Options = []) -> Promise<UIImage> {
		let resource = RESTResource.smallFile(url: nil, path: path)
		let bgq = DispatchQueue.global(qos: .userInitiated)
		return dataTask(resource: resource, options: options).compactMap(on: bgq) { (result: DataResponse) -> UIImage? in
			UIImage(data: result.data)
		}
	}
	
	/// Asynchronously retrieves an image at the given path.
	/// Use this method only for small images, e.g. User.SmallPhotoUrl or User.FullPhotoUrl.
	/// - Parameter url: URL to the image to be retrieved
	/// - Returns: Promise of an image
	public func fetchImage(url: URL, options: Options = []) -> Promise<UIImage> {
		let resource = RESTResource.smallFile(url: url, path: nil)
		let bgq = DispatchQueue.global(qos: .userInitiated)
		return dataTask(resource: resource, options: options).compactMap(on: bgq) { (result: DataResponse) -> UIImage? in
			UIImage(data: result.data)
		}
	}
	
	// MARK: - Miscellaneous

	/// Asynchronously requests information about the current user
	/// See https://help.salesforce.com/articleView?id=remoteaccess_using_openid.htm&type=0
	public func identity(options: Options = []) -> Promise<Identity> {
		let resource = RESTResource.identity(version: configuration.version)
		let validator: Validator = {
			if let httpResp = $0.response as? HTTPURLResponse, httpResp.statusCode == 403 {
				throw Salesforce.Error.unauthorized
			}
			return try Promise.defaultValidator($0)
		}
		return dataTask(resource: resource, options: options, validator: validator)
	}
	
	/// Asynchronously retrieves information about the Salesforce organization ("org")
	/// See: https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_organization.htm
	public func organization(options: Options = []) -> Promise<Organization> {
		return identity(options: options).then {
			self.retrieve(type: "Organization", id: $0.orgID)
		}
	}
	
	/// Asynchronously retrieves information about org limits
	/// - Returns: Promise of a dictionary of Limits, keyed by limit name
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm
	public func limits(options: Options = []) -> Promise<[String:Limit]> {
		let resource = RESTResource.limits(version: configuration.version)
		return dataTask(resource: resource, options: options)
	}
	
	// MARK: - Apex web services
	
	/// Asynchronously calls an Apex method exposed as a REST endpoint.
	/// See https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST
	/// - Parameter method: HTTP method
	/// - Parameter path: String that gets appended to instance URL; should begin with "/"
	/// - Parameter parameters: Dictionary of query string parameters
	/// - Parameter body: Data to be sent in the body of the request, e.g. JSON as Data in the body of a POST request
	/// - Parameter contentType: the MIME type of the request content
	/// - Parameter headers: Dictionary of custom HTTP header values
	/// - Returns: Promise of Data
	public func apex(
		method: String,
		path: String,
		parameters: [String: Any?]? = nil,
		body: Data? = nil,
		contentType: String? = nil,
		headers: [String: String]? = nil,
		options: Options = []) -> Promise<Data> {
		
		let ct = contentType ?? ( method.lowercased() == URLRequest.HTTPMethod.get.rawValue.lowercased() || method == URLRequest.HTTPMethod.delete.rawValue.lowercased() ? URLRequest.MIMEType.urlEncoded : URLRequest.MIMEType.json).rawValue
		let params: [String: String]? = parameters?.mapValues { "\($0 ?? "")" }
		let resource = RESTResource.apex(method: method, path: path, queryParameters: params, body: body, contentType: ct, headers: headers)
		return dataTask(resource: resource, options: options).map { $0.data }
	}
}
