//
//  OAuth2Resource.swift
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation

internal enum OAuth2Resource {
	case refresh(configuration: Configuration)
	case revoke(configuration: Configuration)
}

extension OAuth2Resource: Resource {
	
	func request(with authorization: Authorization) throws -> URLRequest {
		
		switch self {
			
		case let .refresh(configuration):
			return try URLRequest(
				method: .post,
				baseURL: configuration.authorizationURL.deletingLastPathComponent().appendingPathComponent("token"),
				accessToken: authorization.accessToken,
				contentType: .urlEncoded,
				queryParameters: [
					"format" : "json",
					"grant_type": "refresh_token",
					"client_id": configuration.consumerKey,
					"refresh_token": {
						guard let refreshToken = authorization.refreshToken else {
							throw Salesforce.Error.authenticationRequired
						}
						return refreshToken
					}()
				]
			)
						
		case let .revoke(configuration):
			return URLRequest(url: URL(string: "HI")!) //TODO:
		}
	}
}
