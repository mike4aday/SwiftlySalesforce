//
//  OAuthResource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

internal enum OAuthResource {
	case refreshAccessToken(authorizationURL: URL, consumerKey: String)
	case revokeAccessToken(authorizationURL: URL)
	case revokeRefreshToken(authorizationURL: URL)
}

extension OAuthResource: URLRequestConvertible {
	
	func asURLRequest(with authorization: Authorization) throws -> URLRequest {
		
		var url: URL? = nil
		var method: String = "GET"
		var body: Data? = nil
		
		switch self {
			
		case let .refreshAccessToken(authorizationURL, consumerKey):
			guard let refreshToken = authorization.refreshToken else {
				throw Salesforce.Error.refreshTokenUnavailable
			}
			url = URL(string: "token", relativeTo: authorizationURL)
			method = "POST"
			body = [
				"format" : "json",
				"grant_type": "refresh_token",
				"client_id": consumerKey,
				"refresh_token": refreshToken
			].asPercentEncodedString()?.data(using: .utf8)
						
		case let .revokeAccessToken(authorizationURL):
			url = URL(string: "revoke", relativeTo: authorizationURL)
			method = "POST"
			body = ["token" : authorization.accessToken].asPercentEncodedString()?.data(using: .utf8)
			
		case let .revokeRefreshToken(authorizationURL):
			guard let refreshToken = authorization.refreshToken else {
				throw Salesforce.Error.refreshTokenUnavailable
			}
			url = URL(string: "revoke", relativeTo: authorizationURL)
			method = "POST"
			body = ["token" : refreshToken].asPercentEncodedString()?.data(using: .utf8)
		}
		
		guard let u = url else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [:])
		}
		let req = try URLRequest(url: u, authorization: authorization, method: method, body: body, contentType: URLRequest.MIMEType.urlEncoded.rawValue)
		return req
	}
}
