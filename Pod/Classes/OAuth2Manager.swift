//
//  OAuth2Manager.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import Locksmith
import PromiseKit
import Alamofire


public class OAuth2Manager {
	

	
	public static let sharedInstance = OAuth2Manager() // Singleton
	
	public var consumerKey: String? // From Connected App settings
	public var redirectURL: NSURL?  // From Connected App settings, the "Callback URL"
	
	public var hostname: String = "login.salesforce.com" // Host for OAuth2 authorization and authentication
	public weak var authenticationDelegate: AuthenticationDelegate?
	
	internal var pendingAuthorization: (promise: Promise<Credentials>, fulfill: (Credentials) -> (), reject: (ErrorType) -> ())?
	internal var promisedRevocation: Promise<Void>?
	
	
	
	/// Local credentials store. Uses iOS Keychain. Read only.
	public var credentials: Credentials? {
		get {
			guard let dict = Locksmith.loadDataForUserAccount(Constant.CurrentUser.rawValue, inService: Constant.Salesforce.rawValue) else {
				return nil
			}
			let creds = Credentials(dictionary: dict)
			return creds
		}
	}
	
	/// URL to use for user login
	public var authorizationURL: NSURL? {
		
		guard let
			redirectURLString = self.redirectURL?.absoluteString,
			consumerKey = self.consumerKey,
			comps = NSURLComponents(string: "https://\(hostname)/services/oauth2/authorize") else {
			return nil
		}
		
		comps.addQueryItems([
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : redirectURLString,
			"prompt" : "login consent",
			"display" : "touch"])
		return comps.URL
	}
	
	
	
	/// Private initializer
	private init() { }
	
	
	
	/// Convenience method to configure required properties. Call this before referencing shared instance.
	/// - Parameter consumerKey: "Consumer Key" from Salesforce Connected App settings
	/// - Parameter callbackURL: "Callback URL" from Salesforce Connected App settings
	/// - Parameter hostname: authorization hostname; login.salesforce.com, or test.salesforce.com (sandbox), or custom 'my domain' host
	public func configureWithConsumerKey(consumerKey: String, redirectURL: NSURL, hostname: String = "login.salesforce.com") {
		self.consumerKey = consumerKey
		self.redirectURL = redirectURL
		self.hostname = hostname
	}
	
	/// Retrieve credentials for current user, including access token required in HTTP request header.
	/// First tries to use refresh token, if there is one, but if that fails, user has to log in
	/// - Returns: Promise of Credentials
	public func authorize() -> Promise<Credentials> {
		
		if let pending = self.pendingAuthorization where pending.promise.pending {
			return pending.promise
		}
		else {
			
			let pending = Promise<Credentials>.pendingPromise()
			self.pendingAuthorization = pending
			
			if let refreshToken = self.credentials?.refreshToken {
				
				firstly {
					try refreshCredentialsWithToken(refreshToken)
				}.then {
					(credentials) -> () in
					pending.fulfill(credentials)
				}.error {
					(_) -> () in
					do { try self.delegateAuthentication() }
					catch {	pending.reject(error) }
				}
			}
			else {
				do { try self.delegateAuthentication() }
				catch {	pending.reject(error) }
			}
			
			return pending.promise
		}
	}
	
	/// Revokes the stored refresh token or, if the refresh token is not available, then revokes the stored access token.
	/// Salesforce revokes an associated access token, too, when revoking the refresh token.
	/// - Returns: Promise of an NSURL that can be used to clear the user's UI session and complete a client-side logout process
	public func revoke() -> Promise<Void> {
	
		if let promise = self.promisedRevocation where promise.pending {
			return promise
		}
		else {
			
			let promise = Promise<Void> {
				
				fulfill, reject in
				
				guard let token = self.credentials?.refreshToken ?? self.credentials?.accessToken else {
					reject(Error.InvalidState(message: "No token to revoke"))
					return
				}
				
				let URLString = "https://\(self.hostname)/services/oauth2/revoke"
				let params = [ "token": token]
				Alamofire.request(.GET, URLString, parameters: params, encoding: .URL, headers: nil)
					.validate()
					.responseData {
						(response) -> () in
						switch response.result {
						case .Success:
							do {
								try self.clearCredentials()
								fulfill()
							}
							catch {
								reject(error)
							}
						case .Failure:
							// Salesforce doesn't provide an error code or description for GET revoke calls, so we create an error here
							reject(Error.ResponseError(code: "token_revocation_error", description: "Error revoking token"))
						}
				}
			}
			self.promisedRevocation = promise
			return promise
		}
	}
	
	
	/// Authentication delegate should call this when authentication has completed
	public func authenticationCompletedWithResult(result: AuthenticationResult) {
		
		switch result {
		
		case .Success(let credentials):
			do {
				try storeCredentials(credentials)
				if let pending = pendingAuthorization where pending.promise.pending {
					pending.fulfill(credentials)
				}
			}
			catch {
				if let pending = pendingAuthorization where pending.promise.pending {
					pending.reject(error)
				}
			}
		case .Failure(let error):
			if let pending = pendingAuthorization where pending.promise.pending {
				pending.reject(error)
			}
		}
	}
	
	
	//
	// MARK: - Internal functions
	//
	
	internal func refreshCredentialsWithToken(refreshToken: String) throws -> Promise<Credentials> {
		
		guard let consumerKey = self.consumerKey else {
			throw Error.InvalidState(message: "Consumer key not specified")
		}
		
		// TODO: use non-caching URL session to prevent storage of redirect URLs, which may contain
		// parameters, and which may be an issue for AppExchange security review
		let URLString = "https://\(hostname)/services/oauth2/token"
		let params = [
			"format" : "urlencoded",
			"grant_type": "refresh_token",
			"client_id": consumerKey,
			"refresh_token": refreshToken]
		
		return Promise {
			
			fulfill, reject in
			
			Alamofire.request(.POST, URLString, parameters: params, encoding: .URL, headers: nil)
			.responseString {
				(response) -> () in
				switch response.result {
				case .Success(let URLEncodedString):
					
					// HTTP request was successful, but actual refresh request may not have been...
					if let creds = Credentials(URLEncodedString: URLEncodedString, refreshToken: refreshToken) {
						do {
							try self.storeCredentials(creds)
							fulfill(creds)
						}
						catch {
							reject(error)
						}
					}
					else if let error = Error.errorFromURLEncodedString(URLEncodedString) {
						reject(error)
					}
					else {
						// Can't parse the returned string; return as-is
						reject(Error.ResponseError(code: "unknown", description: URLEncodedString))
					}
				case .Failure(let error):
					reject(error)
				}
			}
		}
	}
	
	internal func storeCredentials(credentials: Credentials) throws {
		try Locksmith.updateData(credentials.toDictionary(), forUserAccount: Constant.CurrentUser.rawValue, inService: Constant.Salesforce.rawValue)
	}
	
	internal func clearCredentials() throws {
		
		do {
			try Locksmith.deleteDataForUserAccount(Constant.CurrentUser.rawValue, inService: Constant.Salesforce.rawValue)
		}
		catch {
			// Ignore error if credentials aren't already in the keychain
			guard case LocksmithError.NotFound = error else {
				throw error
			}
		}
	}
	
	internal func delegateAuthentication() throws {
		
		guard let authenticationDelegate = self.authenticationDelegate else {
			throw Error.InvalidState(message: "Invalid authentication delegate")
		}
		guard let authorizationURL = self.authorizationURL else {
			throw Error.InvalidState(message: "Invalid configuration; verify that consumer key and callback URL have been set.")
		}
		
		try authenticationDelegate.authenticateWithURL(authorizationURL)
	}
	
	/// Resets/clears the current instance. Intended for testing.
	internal func reset() throws {
		self.consumerKey = nil
		self.redirectURL = nil
		try self.clearCredentials()
		self.hostname = "login.salesforce.com"
		self.authenticationDelegate = nil
		self.pendingAuthorization = nil
		self.promisedRevocation = nil
	}
}


// MARK: - Extension: Constants
extension OAuth2Manager {
	
	/// Constant strings
	enum Constant: String {
		case CurrentUser, Salesforce
	}
}