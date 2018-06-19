//
//  Salesforce+OAuth2.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation
import PromiseKit
import SafariServices

internal extension Salesforce {
	
	internal func authorize() -> Promise<Authorization> {
		if let promise = self.authorizationPromise, promise.isPending {
			return promise
		}
		else {
			let promise = refresh().recover { _ in self.authenticate() }
			self.authorizationPromise = promise
			return promise
		}
	}
	
	internal func authenticate() -> Promise<Authorization> {
		return Promise<URL> { seal in
			let authURL = configuration.authorizationURL
			let scheme = configuration.callbackURL.scheme
			let session = SFAuthenticationSession(url: authURL, callbackURLScheme: scheme) { url, error in
				seal.resolve(url, error)
			}
			guard session.start() else {
				throw Salesforce.Error.authenticationSessionFailed
			}
			self.authenticationSession = session
		}.map { url -> Authorization in
			let auth = try Authorization(with: url)
			let key = AuthorizationStore.Key(userID: auth.userID, organizationID: auth.orgID, consumerKey: self.configuration.consumerKey)
			try AuthorizationStore.store(auth, for: key)
			self.authorizationStoreKey = key
			return auth
		}
	}
	
	internal func refresh() -> Promise<Authorization> {
	
		return firstly { () -> Promise<(DataResponse, Authorization)> in
			guard let authorization = self.authorization else {
				throw Salesforce.Error.authenticationRequired
			}
			let request = try OAuth2Resource.refresh(configuration: configuration).request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request).map { ($0, authorization) }
		}.map { (dataResponse: DataResponse, oldAuthorization: Authorization) -> Authorization in
			struct RefreshResult: Decodable {
				let id: URL
				let instance_url: URL
				let access_token: String
			}
			let resp = try JSONDecoder().decode(RefreshResult.self, from: dataResponse.data)
			let refreshToken = oldAuthorization.refreshToken // Re-use since we don't get new refresh token
			return Authorization(accessToken: resp.access_token, instanceURL: resp.instance_url, identityURL: resp.id, refreshToken: refreshToken)
		}
	}
}
