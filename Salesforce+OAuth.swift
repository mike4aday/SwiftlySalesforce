//
//  Salesforce+OAuth.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation
import PromiseKit
import SafariServices

extension Salesforce {
	
	public func authorize(authenticateIfRequired: Bool = true) -> Promise<Authorization> {
		if let promise = self.authorizationPromise, promise.isPending {
			return promise
		}
		else {
			let promise = refreshAccessToken().recover { (error) -> Promise<Authorization> in
				guard authenticateIfRequired else {
					throw error
				}
				return self.authenticate()
			}.get { (auth) in
				let key = AuthorizationStore.Key(userID: auth.userID, organizationID: auth.orgID, consumerKey: self.configuration.consumerKey)
				try AuthorizationStore.store(auth, for: key)
				self.authorizationStoreKey = key
			}
			self.authorizationPromise = promise
			return promise
		}
	}
	
	public func revoke() -> Promise<Void> {
		return revokeRefreshToken().recover { (error) -> Promise<Void> in
			return self.revokeAccessToken()
		}.ensure {
			// Remove authorization info from keychain
			if let key = self.authorizationStoreKey {
				try? AuthorizationStore.clear(for: key)
			}
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
			return try Authorization(with: url)
		}
	}
	
	internal func refreshAccessToken() -> Promise<Authorization> {
		return firstly { () -> Promise<(DataResponse, Authorization)> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			let resource = OAuthResource.refreshAccessToken(authorizationURL: config.authorizationURL, consumerKey: config.consumerKey)
			let request = try resource.request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).validated().map { ($0, authorization) }
		}.map { (dataResponse: DataResponse, oldAuth: Authorization) -> Authorization in
			struct RefreshResult: Decodable {
				let id: URL
				let instance_url: URL
				let access_token: String
				let issued_at: String
			}
			let result: RefreshResult = try JSONDecoder().decode(RefreshResult.self, from: dataResponse.data)
			let refreshToken = oldAuth.refreshToken // Re-use since we don't get new refresh token
			let newAuth = Authorization(accessToken: result.access_token, instanceURL: result.instance_url, identityURL: result.id, refreshToken: refreshToken, issuedAt: UInt(result.issued_at))
			return newAuth
		}
	}
	
	internal func revokeRefreshToken() -> Promise<Void> {
		return firstly { () -> Promise<Void> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			let resource = OAuthResource.revokeRefreshToken(authorizationURL: config.authorizationURL)
			let request = try resource.request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).validated().done { _ in return }
		}
	}
	
	internal func revokeAccessToken() -> Promise<Void> {
		return firstly { () -> Promise<Void> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			let resource = OAuthResource.revokeAccessToken(authorizationURL: config.authorizationURL)
			let request = try resource.request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).validated().done { _ in return }
		}
	}
}
