//
//  LoginDelegate.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import SafariServices
import PromiseKit
import Alamofire

public typealias LoginResult = Alamofire.Result<AuthData>

fileprivate final class LoginViewController: SFSafariViewController {
	// Hold reference to the view controller that's temporarily replaced by the login view controller
	var replacedRootViewController: UIViewController?
}

public protocol LoginDelegate {
	var window: UIWindow? { get }
	func login(url: URL) throws
}

// MARK: - Extension
extension LoginDelegate {
	
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
	
	public func login(url: URL) throws {
		
		guard !loggingIn else {
			throw SalesforceError.invalidity(message: "Already logging in!")
		}
		
		guard let window = self.window else {
			throw SalesforceError.invalidity(message: "No valid window!")
		}
		
		// Replace current root view controller with Safari view controller for login
		let loginVC = LoginViewController(url: url)
		loginVC.replacedRootViewController = window.rootViewController
		window.rootViewController = loginVC
	}
	
	public func handleRedirectURL(redirectURL: URL) {
		
		var result:LoginResult
		
		// Note: docs are wrong - error information may be in URL fragment *or* in query string...
		if let urlEncodedString = redirectURL.fragment ?? redirectURL.query, let authData = AuthData(urlEncodedString: urlEncodedString) {
			result = .success(authData)
		}
		else {
			// Can't make sense of the redirect URL
			result = .failure(SalesforceError.unsupportedURL(url: redirectURL))
		}
		
		salesforce.authManager.loginCompleted(result: result)
		if let window = self.window, let currentRootVC = window.rootViewController as? LoginViewController, let replacedRootVC = currentRootVC.replacedRootViewController {
			window.rootViewController = replacedRootVC
		}
	}
	
	/// Call this to initiate logout process.
	/// Revokes OAuth2 refresh and/or access token, then replaces
	/// the current root view controller with a Safari view controller for login
	/// - Returns: Promise<Void>; chain to this for custom post-logout actions
	public func logout() -> Promise<Void> {
		return Promise<Void> {
			fulfill, reject in
			firstly {
				salesforce.authManager.revoke()
			}.then {
				() -> () in
				if let loginURL = try? salesforce.authManager.loginURL(), let window = self.window {
					// Replace current root view controller with Safari view controller for login
					let loginVC = LoginViewController(url: loginURL)
					loginVC.replacedRootViewController = window.rootViewController
					window.rootViewController = loginVC
				}
				fulfill()
			}.catch {
				error -> () in
				reject(error)
			}
		}
	}
}
