//
//  LoginDelegate.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import SafariServices
import PromiseKit

public protocol LoginDelegate: class {
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
			throw ApplicationError.invalidState(message: "Already logging in!")
		}
		
		guard let window = UIApplication.shared.keyWindow else {
			throw ApplicationError.invalidState(message: "No key window!")
		}
		
		// Replace current root view controller with Safari view controller for login
		let loginVC = SafariLoginViewController(url: url)
		loginVC.replacedRootViewController = window.rootViewController
		window.rootViewController = loginVC
	}
	
	/// Handles the redirect URL returned by Salesforce after OAuth2 authentication and authorization.
	/// Restores the root view controller that was replaced by the Salesforce-hosted login web form
	/// - Parameter url: URL returned by Salesforce after OAuth2 authentication & authorization
	/// - Parameter connectedApp: Connected App involved in the current OAuth2 authentication
	public func handleRedirectURL(_ url: URL, for connectedApp: ConnectedApp) {
		
		connectedApp.loginCompleted(redirectURL: url)
		
		// Restore the original root view controller
		if let window = UIApplication.shared.keyWindow, let currentRootVC = window.rootViewController as? LoginViewController, let replacedRootVC = currentRootVC.replacedRootViewController {
			window.rootViewController = replacedRootVC
		}
	}
	
	/// Call this to initiate logout process.
	/// Revokes OAuth2 refresh and/or access token, then replaces
	/// the current root view controller with a Safari view controller for login
	/// - Parameter connectedApp: Connected App from which the current user will log out
	/// - Returns: Promise<Void>; chain to this for custom post-logout actions
	public func logout(from connectedApp: ConnectedApp) -> Promise<Void> {
		return Promise<Void> {
			fulfill, reject in
			firstly {
				connectedApp.revoke()
			}.then {
				() -> () in
				if let loginURL = try? connectedApp.loginURL(), let window = UIApplication.shared.keyWindow {
					// Replace current root view controller with Safari view controller for login
					let loginVC = SafariLoginViewController(url: loginURL)
					loginVC.replacedRootViewController = window.rootViewController
					window.rootViewController = loginVC
				}
				fulfill(())
			}.catch {
				error -> () in
				reject(error)
			}
		}
	}
}
