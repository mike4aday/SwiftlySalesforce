//
//  OAuth2Resource.swift
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation

internal enum OAuthResource {
	case refreshAccessToken(configuration: Salesforce.Configuration)
	case revokeAccessToken(configuration: Salesforce.Configuration)
	case revokeRefreshToken(configuration: Salesforce.Configuration)
}

extension OAuthResource: Resource {
	
	func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .refreshAccessToken(configuration):
			guard let refreshToken = authorization.refreshToken else {
				throw Salesforce.Error.refreshTokenUnavailable
			}
			return try URLRequest(
				method: .post,
				baseURL: configuration.oauthBaseURL.appendingPathComponent("token"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: [
					"format" : "json",
					"grant_type": "refresh_token",
					"client_id": configuration.consumerKey,
					"refresh_token": refreshToken
				]
			)
						
		case let .revokeAccessToken(configuration):
			return try URLRequest(
				method: .post,
				baseURL: configuration.oauthBaseURL.appendingPathComponent("revoke"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: ["token" : authorization.accessToken]
			)
			
		case let .revokeRefreshToken(configuration):
			guard let refreshToken = authorization.refreshToken else {
				throw Salesforce.Error.refreshTokenUnavailable
			}
			return try URLRequest(
				method: .post,
				baseURL: configuration.oauthBaseURL.appendingPathComponent("revoke"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: ["token": refreshToken]
			)
		}
	}
}
