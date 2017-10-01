//
//  ConnectedApp.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit

open class ConnectedApp {
	
	public let consumerKey: String
	public let redirectURL: URL
	public let loginHost: String
	
	weak public var loginDelegate: LoginDelegate?
	
	private var storeKey: OAuth2ResultStore.Key?
	private var pendingAuthorization: (promise: Promise<OAuth2Result>, fulfill: (OAuth2Result) -> (), reject: (Error) -> ())?
	private var promisedRevocation: Promise<Void>?
	
	internal var authData: OAuth2Result? {
		didSet {
			if let key = storeKey {
				if let authData = authData {
					do {
						// Try to securely store the OAuth2 result so user won't have to authenticate on next use
						try OAuth2ResultStore.store(key: key, value: authData)
					}
					catch {
						debugPrint("Unable to save OAuth2 result to secure storage! Error: \(error)")
					}
				}
				else {
					do {
						// authData has been set to nil - delete old data, if any
						try OAuth2ResultStore.clear(key: key)
					}
					catch {
						debugPrint("Unable to clear OAuth2 result from secure storage! Error: \(error)")
					}
				}
			}
		}
	}
	
	public var accessToken: String? {
		return authData?.accessToken
	}
	
	public var instanceURL: URL? {
		return authData?.instanceURL
	}
	
	public var userID: String? {
		return authData?.userID
	}
	
	public var orgID: String? {
		return authData?.orgID
	}
	
	/// Initializer
	/// - Parameter consumerKey: Connected App's consumer key
	/// - Parameter redirectURL: Connected App's redirect URL
	/// - Parameter loginDelegate: will handle user authentication when needed
	/// - Parameter loginHost: Salesforce authorization server (set to "test.salesforce.com" for sandbox org)
	/// - Parameter userID: optional; record ID of user; useful for supporting multi-user switching
	/// - Parameter orgID: optional; record ID of org; useful for supporting mutli-user switching
	/// - Returns: Promise<[ObjectDescription]>, a promise of an array of ObjectDescriptions, in the same order as the "types" parameter.
	public convenience init(consumerKey: String, redirectURL: URL, loginDelegate: LoginDelegate, loginHost: String = "login.salesforce.com", userID: String = "Default User ID", orgID: String = "Default Org. ID") {
		let storeKey = OAuth2ResultStore.Key(userID: userID, orgID: orgID, consumerKey: consumerKey)
		self.init(consumerKey: consumerKey, redirectURL: redirectURL, loginDelegate: loginDelegate, loginHost: loginHost, storeKey: storeKey)
	}
	
	internal init(consumerKey: String, redirectURL: URL, loginDelegate: LoginDelegate, loginHost: String = "login.salesforce.com", storeKey: OAuth2ResultStore.Key?) {
		self.consumerKey = consumerKey
		self.redirectURL = redirectURL
		self.loginDelegate = loginDelegate
		self.loginHost = loginHost
		self.storeKey = storeKey
		if let key = self.storeKey {
			self.authData = OAuth2ResultStore.retrieve(key: key)
		}
	}
	
	/// Builds the login URL with OAuth2 'user-agent' flow parameters
	/// - Returns: login URL
	public func loginURL() throws -> URL {
		let params = [
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : redirectURL.absoluteString,
			"prompt" : "login consent",
			"display" : "touch" ]
		guard let comps = URLComponents(string: "https://\(loginHost)/services/oauth2/authorize", parameters: params), let url = comps.url else {
			throw ApplicationError.invalidState(message: "Cannot construct OAuth2 login URL!")
		}
		return url
	}
	
	/// Called by LoginDelegate when OAuth2 "dance" is completed
	/// - Parameter redirectURL: URL returned by Salesforce after OAuth2 authentication & authorization
	public func loginCompleted(redirectURL: URL) {
		
		// Note: docs are wrong - if the redirect URL contains an error,
		// the error information may be in the URL fragment *or* in the query string...
		if let urlEncodedString = redirectURL.fragment ?? redirectURL.query, let authData = try? OAuth2Result(urlEncodedString: urlEncodedString) {
			self.authData = authData
			if let pending = self.pendingAuthorization, pending.promise.isPending {
				pending.fulfill(authData)
			}
		}
		else {
			// Can't make sense of the redirect URL
			if let pending = self.pendingAuthorization, pending.promise.isPending {
				pending.reject(SerializationError.invalid(redirectURL, message: "Can't parse redirect URL: \(redirectURL)"))
			}
		}
	}
	
	/// Asks Salesforce to authorize user by refreshing the access token
	/// or, if that fails or there's no refresh token, then the user is asked
	/// to re-authenticate via the Salesforce-hosted login web form.
	/// - Returns: Asynchronous 'promise' of OAuth2Result
	internal func authorize() -> Promise<OAuth2Result> {
		if let pending = self.pendingAuthorization, pending.promise.isPending {
			// Already authorizing
			return pending.promise
		}
		else {
			let pending = Promise<OAuth2Result>.pending()
			self.pendingAuthorization = pending
			if let refreshToken = authData?.refreshToken {
				firstly {
					// Attempt to refresh access token
					refresh(refreshToken: refreshToken)
				}.then {
					authData -> () in
					self.authData = authData
					if let p = self.pendingAuthorization, p.promise.isPending {
						p.fulfill(authData)
					}
				}.catch {
					_ in
					do {
						// Refresh attempt failed, so user authentication required
						if let delegate = self.loginDelegate {
							try delegate.login(url: self.loginURL())
						}
						else {
							// Shouldn't happen; delegate is usually UIApplicationDelegate
							// and wouldn't get deallocated
							fatalError("No delegate available to handle user login!")
						}
					}
					catch {
						if let p = self.pendingAuthorization, p.promise.isPending {
							p.reject(error)
						}
					}
				}
			}
			else {
				do {
					// No refresh token available, user authentication required
					if let delegate = loginDelegate {
						try delegate.login(url: loginURL())
					}
					else {
						fatalError("No delegate available to handle user login!")
					}
				}
				catch {
					if let p = self.pendingAuthorization, p.promise.isPending {
						p.reject(error)
					}
				}
			}
			return pending.promise
		}
	}
	
	/// Revokes the stored refresh token or, if the refresh token is not available, then revokes the stored access token.
	/// Depending on the scopes configured in the Salesforce Connected app definition, a refresh token may not be issued upon authentication.
	/// Salesforce revokes any associated access tokens when revoking the refresh token.
	/// Parameter accessTokenOnly: intended for testing; if true, will only attempt to revoke the access token.
	/// See: https://help.salesforce.com/articleView?id=remoteaccess_revoke_token.htm
	/// - Returns: Asynchronous 'promise'
	internal func revoke(accessTokenOnly: Bool = false) -> Promise<Void> {
		if let promise = self.promisedRevocation, promise.isPending {
			return promise
		}
		else {
			let promise = first {
				guard let token = (accessTokenOnly ? self.authData?.accessToken : self.authData?.refreshToken) else {
					return Promise(error: ApplicationError.invalidState(message: "No token to revoke"))
				}
				return Promise(value: token)
			}.then {
				(token: String) -> Promise<Void> in
				let resource = Resource.revoke(token: token, host: self.loginHost)
				return Requestor.data(connectedApp: self, session: URLSession.shared).request(resource: resource).asVoid()
			}
			self.promisedRevocation = promise
			return promise
		}
	}
	
	/// Refreshes the OAuth2 access token
	/// - Parameter refreshToken: The value of the OAuth2 refresh token obtained during authorization
	/// - Returns: Promise of OAuth2Result
	private func refresh(refreshToken: String) -> Promise<OAuth2Result> {
		let resource = Resource.refresh(refreshToken: refreshToken, consumerKey: consumerKey, host: loginHost)
		return Requestor.data(connectedApp: self, session: URLSession.shared).request(resource: resource).asString().then {
			(urlEncodedString) -> OAuth2Result in
			return try OAuth2Result(urlEncodedString: urlEncodedString, refreshToken: refreshToken)
		}
	}
}
