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

extension OAuthResource: Resource {
	
	internal func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .refreshAccessToken(authorizationURL, consumerKey):
			guard let refreshToken = authorization.refreshToken else {
				throw Salesforce.Error.refreshTokenUnavailable
			}
			return try URLRequest(
				method: URLRequest.HTTPMethod.post.rawValue,
				url: baseOAuthURL(from: authorizationURL).appendingPathComponent("token"),
				accessToken: authorization.accessToken,
				additionalQueryParameters: [
					"format" : "json",
					"grant_type": "refresh_token",
					"client_id": consumerKey,
					"refresh_token": refreshToken
				],
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
						
		case let .revokeAccessToken(authorizationURL):
			return try URLRequest(
				method: URLRequest.HTTPMethod.post.rawValue,
				url: baseOAuthURL(from: authorizationURL).appendingPathComponent("revoke"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: ["token" : authorization.accessToken],
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
			
		case let .revokeRefreshToken(authorizationURL):
			guard let refreshToken = authorization.refreshToken else {
				throw Salesforce.Error.refreshTokenUnavailable
			}
			return try URLRequest(
				method: URLRequest.HTTPMethod.post.rawValue,
				url: baseOAuthURL(from: authorizationURL).appendingPathComponent("revoke"),
				body: nil,
				accessToken: authorization.accessToken,
				additionalQueryParameters: ["token": refreshToken],
				additionalHeaders: nil,
				contentType: URLRequest.MIMEType.urlEncoded.rawValue
			)
		}
	}
}

private extension OAuthResource {
	
	// Helper function
	private func baseOAuthURL(from authorizationURL: URL) -> URL {
		var comps = URLComponents(url: authorizationURL.deletingLastPathComponent(), resolvingAgainstBaseURL: false)
		comps?.queryItems = nil
		return comps?.url ?? authorizationURL.deletingLastPathComponent()
	}
}
