//
//  ConnectedApp.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit

/// Represents a Salesforce Connected App.
/// See https://help.salesforce.com/articleView?id=connected_app_overview.htm

open class ConnectedApp {
	
	public let consumerKey: String
	public let callbackURL: URL
	public let loginHost: String
    public let extraUrl: String
	
	weak public var loginDelegate: LoginDelegate?
	
	static public let defaultUserID = "Default User ID"
	static public let defaultOrgID = "Default Org ID"
	static public let defaultLoginHost = "login.salesforce.com"
	
	private var storeKey: OAuth2ResultStore.Key
	private var pendingAuthorization: (promise: Promise<OAuth2Result>, fulfill: (OAuth2Result) -> (), reject: (Error) -> ())?
	private var promisedRevocation: Promise<Void>?
	
	internal var authData: OAuth2Result? {
		didSet {
			if let authData = authData {
				do {
					// Try to securely store the OAuth2 result so user won't have to authenticate on next use
					try OAuth2ResultStore.store(key: storeKey, value: authData)
				}
				catch {
					debugPrint("Unable to save OAuth2 result to secure storage! Error: \(String(describing: error))")
				}
			}
			else {
				do {
					// authData has been set to nil - delete old data, if any
					try OAuth2ResultStore.clear(key: storeKey)
				}
				catch {
					debugPrint("Unable to clear OAuth2 result from secure storage! Error: \(String(describing: error))")
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
	/// - Parameter callbackURL: Connected App's callback URL
	/// - Parameter loginDelegate: will handle user login when needed
	/// - Parameter loginHost: Salesforce authorization server (if sandbox org, set to "test.salesforce.com")
	/// - Parameter userID: record ID of user; useful for supporting multi-user switching
	/// - Parameter orgID: record ID of org; useful for supporting mutli-user switching
    /// - Parameter extraUrl: add extra path to login url
    public convenience init(consumerKey: String, callbackURL: URL, loginDelegate: LoginDelegate, loginHost: String = ConnectedApp.defaultLoginHost, userID: String = ConnectedApp.defaultUserID, orgID: String = ConnectedApp.defaultOrgID, extraUrl: String) {
        self.init(consumerKey: consumerKey, callbackURL: callbackURL, loginDelegate: loginDelegate, loginHost: loginHost, userID: userID, orgID: orgID, authData: nil, extraUrl: extraUrl)
	}
	
	/// Internal initializer
    internal init(consumerKey: String, callbackURL: URL, loginDelegate: LoginDelegate, loginHost: String = ConnectedApp.defaultLoginHost, userID: String = ConnectedApp.defaultUserID, orgID: String = ConnectedApp.defaultOrgID, authData: OAuth2Result? = nil, extraUrl: String = "") {
		
		self.consumerKey = consumerKey
		self.callbackURL = callbackURL
		self.loginDelegate = loginDelegate
		self.loginHost = loginHost
		self.storeKey = OAuth2ResultStore.Key(userID: userID, orgID: orgID, consumerKey: consumerKey)
        self.extraUrl = extraUrl
		
		if let auth = authData {
			self.authData = auth
		}
		else {
			self.authData = OAuth2ResultStore.retrieve(key: storeKey)
		}
	}
	
	/// Builds the login URL with OAuth2 'user-agent' flow parameters
    /// - Parameter extraUrl: add extra path to login url
	/// - Returns: login URL
    public func loginURL(_ extraUrl: String = "") throws -> URL {
		let params = [
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : callbackURL.absoluteString,
			"prompt" : "login consent",
			"display" : "touch" ]
		guard let comps = URLComponents(string: "https://\(loginHost)/services/oauth2/authorize\(extraUrl)", parameters: params), let url = comps.url else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
		}
		return url
	}
	
	/// Called by LoginDelegate when OAuth2 "dance" is completed
	/// - Parameter callbackURL: URL returned by Salesforce after authentication & authorization, and with appended access token
	public func loginCompleted(callbackURL: URL) {
		
		// Note: docs are wrong - if the redirect URL contains an error,
		// the error information may be in the URL fragment *or* in the query string...
		if let urlEncodedString = callbackURL.fragment ?? callbackURL.query, let authData = try? OAuth2Result(urlEncodedString: urlEncodedString) {
			self.authData = authData
			if let pending = self.pendingAuthorization, pending.promise.isPending {
				pending.fulfill(authData)
			}
		}
		else {
			// Can't make sense of the redirect URL
			if let pending = self.pendingAuthorization, pending.promise.isPending {
				pending.reject(ResponseError.invalidAuthorizationData)
			}
		}
	}
	
	/// Revokes the stored refresh token or, if the refresh token is not available, then revokes the stored access token.
	/// Depending on the scopes configured in the Salesforce Connected app definition, a refresh token may not be issued upon authentication.
	/// Salesforce revokes any associated access tokens when revoking the refresh token.
	/// Parameter accessTokenOnly: intended for testing; if true, will only attempt to revoke the access token.
	/// See: https://help.salesforce.com/articleView?id=remoteaccess_revoke_token.htm
	/// - Returns: Asynchronous 'promise'
	public func revoke(accessTokenOnly: Bool = false) -> Promise<Void> {
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
				let resource = Resource.revoke(token: token)
				return Requestor.data.request(resource: resource, connectedApp: self).asVoid()
			}.then {
				() -> () in
				self.authData = nil
			}
			self.promisedRevocation = promise
			return promise
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
							try delegate.login(url: self.loginURL(self.extraUrl))
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
						try delegate.login(url: loginURL(self.extraUrl))
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
	
	/// Refreshes the OAuth2 access token
	/// - Parameter refreshToken: The value of the OAuth2 refresh token obtained during authorization
	/// - Returns: Promise of OAuth2Result
	private func refresh(refreshToken: String) -> Promise<OAuth2Result> {
		let resource = Resource.refresh(refreshToken: refreshToken, consumerKey: consumerKey)
		return Requestor.data.request(resource: resource, connectedApp: self).asString().then {
			(urlEncodedString) -> OAuth2Result in
			return try OAuth2Result(urlEncodedString: urlEncodedString, refreshToken: refreshToken)
		}
	}
}
