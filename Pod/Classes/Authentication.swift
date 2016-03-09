//
//  Authentication.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import PromiseKit


public enum AuthenticationResult {
	case Success(credentials: Credentials)
	case Failure(error: ErrorType)
}


public protocol AuthenticationDelegate: class {
	func authenticateWithURL(URL: NSURL) throws
}


public protocol LoginViewPresentable: class, AuthenticationDelegate {
	var window: UIWindow? { get }
}


/// App delegates should implement this protocol to enable SwiftlySalesforce's
/// default login behavior
internal final class LoginViewController: SFSafariViewController {
	var replacedRootViewController: UIViewController?
}


// MARK: - Extension
extension AuthenticationDelegate {
	
	/// Parses the callback URL for URL-encoded name/value pairs that indicate success or failure.
	public func resultFromRedirectURL(redirectURL: NSURL) throws -> AuthenticationResult {
		
		// TODO: docs are wrong... Error information may be in URL fragment *or* in query string...
		guard let encodedResult = redirectURL.fragment ?? redirectURL.query else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSURLErrorFailingURLErrorKey: redirectURL])
		}
		
		if let creds = Credentials(URLEncodedString: encodedResult) {
			return .Success(credentials: creds)
		}
		else if let error = Error.errorFromURLEncodedString(encodedResult) {
			return .Failure(error: error)
		}
		else {
			// Can't make sense of the callback URL
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSURLErrorFailingURLErrorKey: redirectURL])
		}
	}
}


// MARK: - Extension
extension LoginViewPresentable {
	
	/// Implement AuthenticationDelegate.authenticateWithURL(URL: NSURL)
	public func authenticateWithURL(URL: NSURL) throws {
		try startLoginWithURL(URL)
	}
	
	public var loggingIn: Bool {
		get {
			if let _ = window?.rootViewController as? LoginViewController {
				return true
			}
			else {
				return false
			}
		}
	}
	
	public func handleRedirectURL(redirectURL: NSURL) {
		let result: AuthenticationResult
		do {
			result = try resultFromRedirectURL(redirectURL)
		}
		catch {
			result = .Failure(error: error)
		}
		defer {
			OAuth2Manager.sharedInstance.authenticationCompletedWithResult(result)
			if let window = self.window,
				currentRootViewController = window.rootViewController as? LoginViewController,
				replacedViewController = currentRootViewController.replacedRootViewController {
				
				window.rootViewController = replacedViewController
			}
		}
	}
	
	/// Override to customize login behavior
	public func startLoginWithURL(loginURL: NSURL) throws {
		
		guard !loggingIn else {
			throw Error.InvalidState(message: "Already logging in!")
		}
		
		guard let window = self.window else {
			throw Error.InvalidState(message: "No valid window!")
		}
			
		// Replace current root view controller with Safari view controller for login
		let loginVC = LoginViewController(URL: loginURL)
		loginVC.replacedRootViewController = window.rootViewController
		window.rootViewController = loginVC
	}
	
	/// Call this to initiate logout process.
	/// Revokes OAuth2 refresh and/or access token, then replaces
	/// the current root view controller with a Safari view controller for login
	/// - Returns: Promise<Void>; chain to this for custom post-logout actions
	public func logOut() -> Promise<Void> {
		
		return Promise<Void> {
			
			(fulfill, reject) in
			
			firstly {
				OAuth2Manager.sharedInstance.revoke()
			}.then {
				() -> () in
				if let loginURL = OAuth2Manager.sharedInstance.authorizationURL, window = self.window {
				
					// Replace current root view controller with Safari view controller for login
					let loginVC = LoginViewController(URL: loginURL)
					loginVC.replacedRootViewController = window.rootViewController
					window.rootViewController = loginVC
				}
				fulfill()
			}.error {
				(error) -> () in
				reject(error)
			}
		}
	}
}