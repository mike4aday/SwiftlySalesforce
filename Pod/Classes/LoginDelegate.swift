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

public protocol LoginDelegate {
	func login(url: URL) throws
}

public protocol LoginViewController: class {
	var replacedRootViewController: UIViewController? {
		get set
	}
}

fileprivate final class SafariLoginViewController: SFSafariViewController, LoginViewController {
	// Hold reference to the view controller that's temporarily replaced by the login view controller
	var replacedRootViewController: UIViewController?
}

// MARK: - Extension
extension LoginDelegate {
	
	public var loggingIn: Bool {
		get {
			if let _ = UIApplication.shared.keyWindow?.rootViewController as? LoginViewController {
				return true
			}
			else {
				return false
			}
		}
	}
	
	/// Initiates login process by replacing current root view controller with
	/// Salesforce-hosted webform, per OAuth2 "user-agent" flow. This is the prescribed
	/// authentication method, as the client app does not access the user credentials.
	/// See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_user_agent_oauth_flow.htm
	/// - Parameter url: Salesforce authorization URL
	public func login(url: URL) throws {
		
		guard !loggingIn else {
			throw SalesforceError.invalidity(message: "Already logging in!")
		}
		
		guard let window = UIApplication.shared.keyWindow else {
			throw SalesforceError.invalidity(message: "No valid window!")
		}
		
		// Replace current root view controller with Safari view controller for login
		let loginVC = SafariLoginViewController(url: url)
		loginVC.replacedRootViewController = window.rootViewController
		window.rootViewController = loginVC
	}
	
	/// Handles the redirect URL returned by Salesforce after OAuth2 authentication and authorization.
	/// Restores the root view controller that was replaced by the Salesforce-hosted login web form
	/// - Parameter url: URL returned by Salesforce after OAuth2 authentication & authorization
	public func handleRedirectURL(url: URL) {
		
		var result:LoginResult
		
		// Note: docs are wrong - error information may be in URL fragment *or* in query string...
		if let urlEncodedString = url.fragment ?? url.query, let authData = AuthData(urlEncodedString: urlEncodedString) {
			result = .success(authData)
		}
		else {
			// Can't make sense of the redirect URL
			result = .failure(SalesforceError.unsupportedURL(url: url))
		}
		salesforce.authManager.loginCompleted(result: result)
		
		// Restore the original root view controller
		if let window = UIApplication.shared.keyWindow, let currentRootVC = window.rootViewController as? LoginViewController, let replacedRootVC = currentRootVC.replacedRootViewController {
			window.rootViewController = replacedRootVC
		}

	}
	
	@available(*, deprecated: 3.1.0, message: "Parameter 'redirectURL' renamed to 'url.' Call handleRedirectURL(url: URL) instead.")
	public func handleRedirectURL(redirectURL: URL) {
		return handleRedirectURL(url: redirectURL)
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
				if let loginURL = try? salesforce.authManager.loginURL(), let window = UIApplication.shared.keyWindow {
					// Replace current root view controller with Safari view controller for login
					let loginVC = SafariLoginViewController(url: loginURL)
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
