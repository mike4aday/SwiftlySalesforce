//
//  AuthenticationManager.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import Alamofire
import Locksmith


public protocol LoginDelegate: class {
	func loginWithURL(URL: NSURL)
	func loginCompleted()
}


public protocol LogoutDelegate: class {
	func logoutWithURL(URL: NSURL, startURL: NSURL)
}


public final class AuthenticationManager {
	
	/// Notification names
	public static let AuthenticationSucceeded = "AuthenticationSucceeded"
	public static let AuthenticationCanceled = "AuthenticationCanceled"
	public static let AuthorizationRevoked = "AuthorizationRevoked"
	
	/// Singleton
	public static let sharedInstance = AuthenticationManager()
	
	/// Connected app settings
	public var consumerKey: String!
	public var callbackURL: NSURL!
	
	/// Authorization & login host
	public var hostname: String = "login.salesforce.com"
	
	/// Login, logout delegates
	public weak var loginDelegate: LoginDelegate?
	public weak var logoutDelegate: LogoutDelegate?
	
	/// Flag indicating that authentication is in-progress
	var authenticating = false
	
	var loginURL: NSURL {
		let comps = NSURLComponents(string: "https://\(hostname)/services/oauth2/authorize")!
		comps.addQueryItems([
			"response_type" : "token",
			"client_id" : consumerKey,
			"redirect_uri" : callbackURL.URLString,
			"display" : "touch"])
		return comps.URL!
	}
	
	public internal(set) var credentials: Credentials? {
		get {
			if let dict = Locksmith.loadDataForUserAccount("Current User", inService: "Salesforce") {
				return Credentials(dictionary: dict)
			}
			else {
				return nil
			}
		}
		set {
			if let val = newValue {
				guard let _ = try? Locksmith.updateData(val.toDictionary(), forUserAccount: "Current User", inService: "Salesforce") else {
					NSLog("Failed to save updated credentials in Keychain")
					return
				}
			}
			else {
				// Caller set to nil, so delete from keychain
				guard let _ = try? Locksmith.deleteDataForUserAccount("Current User", inService: "Salesforce") else {
					NSLog("Failed to remove credentials from Keychain")
					return
				}
			}
		}
	}
	
	private init() { }
	
	/// Convenience method to configure required properties. Call this before referencing shared instance.
	/// - Parameter consumerKey: From Salesforce Connected App settings
	/// - Parameter callbakURL: From Salesforce Connected App settings
	/// - Parameter hostname: login.salesforce.com, or test.salesforce.com (sandbox), or custom 'my domain' host
	public func configureWithConsumerKey(consumerKey: String, callbackURL: NSURL, hostname: String = "login.salesforce.com") {
		(self.consumerKey = consumerKey, self.callbackURL = callbackURL, self.hostname = hostname)
	}
	
	public func authenticate() {
		
		guard !authenticating else { return }
		
		authenticating = true
		
		// Try to refresh access token, if we have refresh token
		if let refreshToken = credentials?.refreshToken {
			
			// TODO: use non-caching URL session to prevent storage of redirect URLs, which may contain
			// parameters, and which may be an issue for AppExchange security review
			let URLString = "https://\(hostname)/services/oauth2/token"
			let params = [
				"grant_type": "refresh_token",
				"client_id": consumerKey,
				"refresh_token": refreshToken
			]
			Alamofire.request(.POST, URLString, parameters: params, encoding: .URL, headers: nil)
			.validate()
			.responseJSON(completionHandler: {
				
				[unowned self]
				(response) -> Void in
				
				switch response.result {
				case .Success(let value):
					// Access token refreshed successfully
					guard let creds = Credentials(json: value, refreshToken: refreshToken) else {
						self.login()
						return
					}
					self.credentials = creds
					self.authenticating = false
					NSNotificationCenter.defaultCenter().postNotificationName(AuthenticationManager.AuthenticationSucceeded, object: self)
				case .Failure(let error):
					NSLog("Failed to refresh access token: %@", error)
					self.login()
				}
			})
		}
		else {
			// User login required
			login()
		}
	}
	
	/// Revokes the refresh token or, if the refresh token is unavailable, then revokes the acces token.
	/// Note that Salesforce revokes an associated access token, too, when revoking the refresh token.
	public func revokeAuthorization() {
		
		guard let token = credentials?.refreshToken ?? credentials?.accessToken else { return }
		
		let URLString = "https://\(hostname)/services/oauth2/revoke"
		let params = [ "token": token]
		Alamofire.request(.GET, URLString, parameters: params, encoding: .URL, headers: nil)
			.validate()
			.responseData {
				
				[unowned self]
				(response) -> Void in
				
				switch response.result {
				case .Success:
					NSLog("Authorization revoked")
					if let instanceURL = self.credentials?.instanceURL {
						self.logout(instanceURL)
					}
					self.credentials = nil
					NSNotificationCenter.defaultCenter().postNotificationName(AuthenticationManager.AuthorizationRevoked, object: self)
				case .Failure(let error):
					NSLog("Failed to revoke authorization: %@", error)
				}
		}
	}
	
	/// Upon successful authorization, Salesforce appends access & refresh tokens (and other stuff) to the Connected App's
	/// callback URL, and then redirects the browser view to that URL. The UIApplicationDelegate receives the URL, and can 
	/// then call this method to provide the tokens, and end the OAuth2 "dance"
	/// - Parameter credentials: Struct containing access token, refresh token, etc.
	public func loginCompletedWithCredentials(credentials: Credentials) {
		self.credentials = credentials
		self.authenticating = false
		loginDelegate?.loginCompleted()
		NSNotificationCenter.defaultCenter().postNotificationName(AuthenticationManager.AuthenticationSucceeded, object: self)
	}
	
	/// Caller's use this to indicate that a user has canceled the login process, usually by pressing "Done" in the 
	/// browser view used to log in to Salesforce
	public func loginCanceled() {
		self.authenticating = false
		NSNotificationCenter.defaultCenter().postNotificationName(AuthenticationManager.AuthenticationCanceled, object: self)
	}
	
	private func login() {
		guard let delegate = loginDelegate else {
			NSLog("Login delegate not available")
			return
		}
		delegate.loginWithURL(loginURL)
	}
	
	private func logout(instanceURL: NSURL) {
		guard let delegate = logoutDelegate else {
			NSLog("Logout delegate not available")
			return
		}
		let logoutURL = instanceURL.URLByAppendingPathComponent("/secur/logout.jsp")
		delegate.logoutWithURL(logoutURL, startURL: loginURL)
	}
}