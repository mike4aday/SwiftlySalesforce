//
//  Salesforce+Configuration.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension Salesforce.Configuration {
	
	public init(consumerKey: String,
				callbackURL: URL,
				authorizationURL: URL) throws {
		
		self.init(consumerKey: consumerKey, callbackURL: callbackURL, authorizationURL: authorizationURL, version: Salesforce.Configuration.defaultVersion)
	}
	
	public init(consumerKey: String,
				callbackURL: URL,
				authorizationHost: String? = nil,
				authorizationParameters: [String: String]? = nil,
				version: String? = nil) throws {
		
		let defaultParams: [String: String] = [
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : callbackURL.absoluteString,
			"prompt" : "login consent",
			"display" : "touch" ]
		let params = defaultParams.merging(authorizationParameters ?? [:], uniquingKeysWith: { (_, new) in new })
		
		let urlString = "https://\(authorizationHost ?? Salesforce.Configuration.defaultAuthorizationHost)/services/oauth2/authorize"
		guard var comps = URLComponents(string: urlString) else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLErrorKey: urlString])
		}
		comps.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
		guard let authorizationURL = comps.url else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLErrorKey: urlString])
		}
		
		self.init(consumerKey: consumerKey, callbackURL: callbackURL, authorizationURL: authorizationURL, version: version ?? Salesforce.Configuration.defaultVersion)
	}
}

/// This extension conforms Configuration to the Decodable protocol, so you
/// could configure your Salesforce app from a JSON file
extension Salesforce.Configuration: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case consumerKey
		case callbackURL
		case authorizationURL
		case authorizationHost
		case authorizationParameters
		case version
	}
	
	public init(from decoder: Decoder) throws {
		
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		// Required
		let consumerKey = try values.decode(String.self, forKey: .consumerKey)
		let callbackURL = try values.decode(URL.self, forKey: .callbackURL)
		
		// Optional
		let authorizationURL = try values.decodeIfPresent(URL.self, forKey: .authorizationURL)
		let authorizationHost = try values.decodeIfPresent(String.self, forKey: .authorizationHost)
		let authorizationParameters = try values.decodeIfPresent([String:String].self, forKey: .authorizationParameters)
		let version = try values.decodeIfPresent(String.self, forKey: .version)
		
		if let authURL = authorizationURL {
			self.init(consumerKey: consumerKey, callbackURL: callbackURL, authorizationURL: authURL, version: version ?? Salesforce.Configuration.defaultVersion)
		}
		else {
			try self.init(consumerKey: consumerKey, callbackURL: callbackURL, authorizationHost: authorizationHost, authorizationParameters: authorizationParameters, version: version)
		}
	}
}
