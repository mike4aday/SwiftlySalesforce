//
//  Salesforce+Request.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation
import SafariServices
import PromiseKit

internal extension Salesforce {
	
	internal func authorize() -> Promise<Authorization> {
		if let promise = self.authorizationPromise, promise.isPending {
			return promise
		}
		else {
			let promise = Promise<URL> { seal in
				let authURL = configuration.authorizationURL
				let scheme = configuration.callbackURL.scheme
				let session = SFAuthenticationSession(url: authURL, callbackURLScheme: scheme) { url, error in
					seal.resolve(url, error)
				}
				guard session.start() else {
					throw AuthorizationError.sessionStartFailure
				}
				authorizationSession = session
			}.map { url -> Authorization in
				let auth = try Authorization(with: url)
				let key = AuthorizationStore.Key(userID: auth.userID, organizationID: auth.orgID, consumerKey: self.configuration.consumerKey)
				try AuthorizationStore.store(auth, for: key)
				self.authorizationStoreKey = key
				return auth
			}
			self.authorizationPromise = promise
			return promise
		}
	}
	
	internal func dataTask(resource: Resource, shouldAuthorize: Bool = true, validator: Validator<DataResponse>? = nil) -> Promise<DataResponse> {
		
		let go: (Authorization) throws -> Promise<DataResponse> = {
			URLSession.shared.dataTask(.promise, with: try resource.request(with: $0)).validated(with: validator)
		}
		
		return firstly { () -> Promise<DataResponse> in
			guard let auth = self.authorization else {
				throw Salesforce.ErrorResponse.unauthorized
			}
			return try go(auth)
		}.recover { error -> Promise<DataResponse> in
			guard case ErrorResponse.unauthorized = error, shouldAuthorize else {
				throw error
			}
			return self.authorize().then { auth in
				return try go(auth)
			}
		}
	}
	
	internal func dataTask<T: Decodable>(resource: Resource, shouldAuthorize: Bool = true, validator: Validator<DataResponse>? = nil) -> Promise<T> {
		return dataTask(resource: resource, shouldAuthorize: shouldAuthorize, validator: validator).map {
			return try JSONDecoder().decode(T.self, from: $0.data)
		}
	}
}

