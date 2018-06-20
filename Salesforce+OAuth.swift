//
//  Salesforce+OAuth2.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation
import PromiseKit
import SafariServices

extension Salesforce {
	
	open func authorize() -> Promise<Authorization> {
		if let promise = self.authorizationPromise, promise.isPending {
			return promise
		}
		else {
			let promise = refreshAccessToken().recover { (error) -> Promise<Authorization> in
				// Refresh failed for some reason, so authenticate user
				return self.authenticate()
			}
			self.authorizationPromise = promise
			return promise
		}
	}
	
	open func revoke() -> Promise<Void> {
		return revokeRefreshToken().recover { (error) -> Promise<Void> in
			return self.revokeAccessToken()
		}
	}
}

internal extension Salesforce {
	
	internal func authenticate() -> Promise<Authorization> {
		return Promise<URL> { seal in
			let authURL = configuration.authorizationURL
			let scheme = configuration.callbackURL.scheme
			let session = SFAuthenticationSession(url: authURL, callbackURLScheme: scheme) { url, error in
				seal.resolve(url, error)
			}
			self.authenticationSession = session
			guard session.start() else {
				throw Salesforce.Error.authenticationSessionFailed
			}
		}.map { url -> Authorization in
			let auth = try Authorization(with: url)
			let key = AuthorizationStore.Key(userID: auth.userID, organizationID: auth.orgID, consumerKey: self.configuration.consumerKey)
			try AuthorizationStore.store(auth, for: key)
			self.authorizationStoreKey = key
			return auth
		}
	}
	
	internal func refreshAccessToken() -> Promise<Authorization> {
		return firstly { () -> Promise<(DataResponse, Authorization)> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			let request = try OAuthResource.refreshAccessToken(configuration: configuration).request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).validated().map { ($0, authorization) }
		}.map { (dataResponse: DataResponse, oldAuthorization: Authorization) -> Authorization in
			struct RefreshResult: Decodable {
				let id: URL
				let instance_url: URL
				let access_token: String
			}
			let result: RefreshResult = try JSONDecoder().decode(RefreshResult.self, from: dataResponse.data)
			let refreshToken = oldAuthorization.refreshToken // Re-use since we don't get new refresh token
			return Authorization(accessToken: result.access_token, instanceURL: result.instance_url, identityURL: result.id, refreshToken: refreshToken)
		}
	}
	
	internal func revokeRefreshToken() -> Promise<Void> {
		return firstly { () -> Promise<Void> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			let request = try OAuthResource.revokeRefreshToken(configuration: configuration).request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).validated().done { _ in return }
		}
	}
	
	internal func revokeAccessToken() -> Promise<Void> {
		return firstly { () -> Promise<Void> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			let request = try OAuthResource.revokeAccessToken(configuration: configuration).request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).validated().done { _ in return }
		}
	}
}
