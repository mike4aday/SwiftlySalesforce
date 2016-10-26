//
//  AuthManager.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit
import Alamofire

open class AuthManager {
	
	/// Configuration used by AuthManager
	public struct Configuration {
		
		public let consumerKey: String
		public let redirectURL: URL
		public let loginHost: String
		public let loginDelegate: LoginDelegate
		
		public init(consumerKey: String, redirectURL: URL, loginHost: String = "login.salesforce.com", loginDelegate: LoginDelegate) {
			self.consumerKey = consumerKey
			self.redirectURL = redirectURL
			self.loginHost = loginHost
			self.loginDelegate = loginDelegate
		}
	}
	
	/// ********************
	/// *** MUST BE SET! ***
	/// ********************
	open var configuration: Configuration!
	
	fileprivate var pendingAuthorization: (promise: Promise<AuthData>, fulfill: (AuthData) -> (), reject: (Error) -> ())?
	fileprivate var promisedRevocation: Promise<Void>?
	
	/// Property which contains data returned by Salesforce after successful OAuth2 authorization, including
	/// access token, optional refresh token, identity URL, and instance URL. The 'didSet' observer attempts to
	/// store the value in the secure iOS keychain, so the user (may) not have to re-authenticate on next app launch.
	public internal(set) var authData: AuthData? = AuthDataStore.shared.retrieve(username: Constant.currentUsername.rawValue) {
		didSet {
			if let data = authData {
				do {
					try AuthDataStore.shared.store(authData: data, username: Constant.currentUsername.rawValue)
				}
				catch {
					debugPrint("Unable to save OAuth2 result to secure storage! Error: \(error)")
				}
			}
			else {
				do {
					try AuthDataStore.shared.clear(username: Constant.currentUsername.rawValue)
				}
				catch {
					debugPrint("Unable to clear OAuth2 result from secure storage! Error: \(error)")
				}
			}
		}
	}
	
	/// Initializers
	
	public init() {
	}
	
	public init(configuration: Configuration) {
		self.configuration = configuration
	}
	
	/// Called by LoginDelegate when OAuth2 "dance" is completed
	/// - Parameter result: result of the login attempt
	open func loginCompleted(result: LoginResult) {
		switch result {
		case .success(let authData):
			self.authData = authData
			if let pending = self.pendingAuthorization, pending.promise.isPending {
				pending.fulfill(authData)
			}
		case .failure(let error):
			if let pending = self.pendingAuthorization, pending.promise.isPending {
				pending.reject(error)
			}
		}
	}
	
	/// Retrieves AuthData (i.e. successful OAuth2 result) from Salesforce, either
	/// by refreshing the access token, or if that fails or there's no refresh token,
	/// then the user is asked to authenticate via the Salesforce login web form.
	/// - Returns: Asynchronous 'promise' of AuthData
	internal func authorize() -> Promise<AuthData> {
		if let pending = self.pendingAuthorization, pending.promise.isPending {
			// Already authorizing
			return pending.promise
		}
		else {
			let pending = Promise<AuthData>.pending()
			self.pendingAuthorization = pending
			if let refreshToken = authData?.refreshToken {
				firstly {
					// Attempt to refresh access token
					refresh(refreshToken: refreshToken)
				}.then {
					authData -> () in
					if let p = self.pendingAuthorization, p.promise.isPending {
						p.fulfill(authData)
					}
				}.catch {
					_ in
					do {
						// Refresh attempt failed, so user authentication required
						try self.configuration.loginDelegate.login(url: self.loginURL())
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
					try configuration.loginDelegate.login(url: loginURL())
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
	/// Salesforce revokes an associated access token, too, when revoking the refresh token.
	/// - Returns: Asynchronous 'promise'
	internal func revoke() -> Promise<Void> {
		if let promise = self.promisedRevocation, promise.isPending {
			return promise
		}
		else {
			let promise = Promise<Void> {
				fulfill, reject in
				guard let token = self.authData?.refreshToken ?? self.authData?.accessToken else {
					reject(SalesforceError.invalidity(message: "No token to revoke"))
					return
				}
				let urlString = "https://\(self.configuration.loginHost)/services/oauth2/revoke"
				Alamofire.request(urlString, parameters: ["token": token], encoding: URLEncoding.default)
					.validate()
					.responseData {
						response in
						switch response.result {
						case .success:
							self.authData = nil
							fulfill()
						case .failure:
							// Salesforce doesn't provide an error code or description for GET revoke calls, so we create an error here
							reject(SalesforceError.responseFailure(code: "TOKEN_REVOCATION_ERROR", message: "Error revoking token", fields: nil))
						}
				}
			}
			self.promisedRevocation = promise
			return promise
		}
	}
	
	/// Builds the login URL with OAuth2 'user-agent' flow parameters
	/// - Returns: login URL
	internal func loginURL() throws -> URL {
		let params = [
			"response_type" : "token",
			"client_id" : configuration.consumerKey,
			"redirect_uri" : configuration.redirectURL.absoluteString,
			"prompt" : "login consent",
			"display" : "touch" ]
		guard let comps = URLComponents(string: "https://\(configuration.loginHost)/services/oauth2/authorize", parameters: params), let url = comps.url else {
			throw SalesforceError.invalidity(message: "Invalid OAuth2 login URL")
		}
		return url
	}
	
	/// Refreshes the OAuth2 access token
	/// - Parameter refreshToken: The value of the OAuth2 refresh token obtained during authorization
	/// - Returns: Promise of AuthData
	internal func refresh(refreshToken: String) -> Promise<AuthData> {
		
		let urlString = "https://\(configuration.loginHost)/services/oauth2/token"
		let params = [
			"format" : "urlencoded",
			"grant_type": "refresh_token",
			"client_id": configuration.consumerKey,
			"refresh_token": refreshToken]
		
		return Promise {
			fulfill, reject in
			Alamofire.request(URL(string: urlString)!, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString {
				response in
				switch response.result {
				case .success(let urlEncodedString):
					guard let authData = AuthData(urlEncodedString: urlEncodedString, refreshToken: refreshToken) else {
						reject(SalesforceError.invalidity(message: "Unable to parse response from OAuth2 refresh token flow: \(urlEncodedString)"))
						return
					}
					self.authData = authData
					fulfill(authData)
				case .failure(let error):
					reject(error)
				}
			}
		}
	}
}

// MARK: - Extension: Constants
fileprivate extension AuthManager {
	
	/// Constant strings
	enum Constant: String {
		case currentUsername, Salesforce
	}
}
