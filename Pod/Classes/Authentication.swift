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
	case success(credentials: Credentials)
	case failure(error: Error)
}


public protocol AuthenticationDelegate: class {
	func authenticateWithURL(_ URL: URL) throws
}


public protocol LoginViewPresentable: class, AuthenticationDelegate {
	var window: UIWindow? { get }
}


internal final class LoginViewController: SFSafariViewController {
	
	// Hold reference to the view controller that's temporarily replaced by the login view controller
	var replacedRootViewController: UIViewController?
}


// MARK: - Extension
extension AuthenticationDelegate {
	
	/// Parses the callback URL for URL-encoded name/value pairs that indicate success or failure.
	public func resultFromRedirectURL(_ redirectURL: URL) throws -> AuthenticationResult {
		
		// TODO: docs are wrong... Error information may be in URL fragment *or* in query string...
		guard let encodedResult = redirectURL.fragment ?? redirectURL.query else {
			throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSURLErrorFailingURLErrorKey: redirectURL])
		}
		
		if let creds = Credentials(URLEncodedString: encodedResult) {
			return .success(credentials: creds)
		}
		else if let error = SFError.errorFromURLEncodedString(encodedResult) {
			return .failure(error: error)
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
	public func authenticateWithURL(_ URL: Foundation.URL) throws {
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
	
	public func handleRedirectURL(_ redirectURL: URL) {
		let result: AuthenticationResult
		do {
			result = try resultFromRedirectURL(redirectURL)
		}
		catch {
			result = .failure(error: error)
		}
		defer {
			OAuth2Manager.sharedInstance.authenticationCompletedWithResult(result)
			if let window = self.window,
				let currentRootViewController = window.rootViewController as? LoginViewController,
				let replacedViewController = currentRootViewController.replacedRootViewController {
				
				window.rootViewController = replacedViewController
			}
		}
	}
	
	/// Override to customize login behavior
	public func startLoginWithURL(_ loginURL: URL) throws {
		
		guard !loggingIn else {
			throw SFError.invalidState(message: "Already logging in!")
		}
		
		guard let window = self.window else {
			throw SFError.invalidState(message: "No valid window!")
		}
			
		// Replace current root view controller with Safari view controller for login
		let loginVC = LoginViewController(url: loginURL)
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
				if let loginURL = OAuth2Manager.sharedInstance.authorizationURL, let window = self.window {
				
					// Replace current root view controller with Safari view controller for login
					let loginVC = LoginViewController(url: loginURL)
					loginVC.replacedRootViewController = window.rootViewController
					window.rootViewController = loginVC
				}
				fulfill()
			}.catch {
				(error) -> () in
				reject(error)
			}
		}
	}
}
