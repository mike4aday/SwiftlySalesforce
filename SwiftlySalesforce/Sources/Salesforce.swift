//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import SafariServices
import PromiseKit

public class Salesforce {
	
	public struct User {
		let userID: String
		let organizationID: String
	}
	
	public let configuration: Configuration
	
	internal var authorizationPromise: Promise<Authorization>?
	internal var authorizationSession: SFAuthenticationSession?
	internal var authorizationStoreKey: AuthorizationStore.Key?
	
	public var authorization: Authorization? {
		guard let key = self.authorizationStoreKey else {
			return nil
		}
		return AuthorizationStore.retrieve(for: key)
	}
	
	public var accessToken: String? {
		return authorization?.accessToken
	}
	
	public init(configuration: Configuration, user: User? = nil) {
		self.configuration = configuration
		if let u = user {
			authorizationStoreKey = AuthorizationStore.Key(userID: u.userID, organizationID: u.organizationID, consumerKey: configuration.consumerKey)
		}
		else {
			authorizationStoreKey = AuthorizationStore.lastStoredKey
		}
	}
}

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
	
	internal func refresh(authorization: Authorization) -> Promise<Authorization> {
		
		struct RefreshResult: Decodable {
			let id: URL
			let instance_url: URL
			let access_token: String
		}
		
		return firstly { () -> Promise<DataResponse> in
			let resource = OAuth2Resource.refresh(configuration: configuration)
			let request = try resource.request(with: authorization)
			return URLSession.shared.dataTask(.promise, with: request)
		}.map { (dataResponse: DataResponse) -> Authorization in
			let resp = try JSONDecoder().decode(RefreshResult.self, from: dataResponse.data)
			let refreshToken = authorization.refreshToken // Re-use since we don't get new refresh token here
			return Authorization(accessToken: resp.access_token, instanceURL: resp.instance_url, identityURL: resp.id, refreshToken: refreshToken)
		}
	}
	
	internal func dataTask(resource: Resource, shouldAuthorize: Bool = true, validator: DataResponseValidator? = nil) -> Promise<DataResponse> {
		
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
			return self.authorize().then { auth -> Promise<DataResponse> in
				return try go(auth)
			}
		}
	}
	
	internal func dataTask<T: Decodable>(resource: Resource, shouldAuthorize: Bool = true, validator: DataResponseValidator? = nil) -> Promise<T> {
		return dataTask(resource: resource, shouldAuthorize: shouldAuthorize, validator: validator).map {
			return try JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(T.self, from: $0.data)
		}
	}
}

