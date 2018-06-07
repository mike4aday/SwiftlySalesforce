//
//  LoginDelegate.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
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

// MARK: -
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
			throw ApplicationError.invalidState(message: "Login already in progress.")
		}
		
		guard let window = UIApplication.shared.keyWindow else {
			throw ApplicationError.invalidState(message: "No key window for login view.")
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
	public func handleCallbackURL(_ url: URL, for connectedApp: ConnectedApp) {
		
		connectedApp.loginCompleted(callbackURL: url)
		
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

// MARK: - Extension constrained to UIApplicationDelegate
extension LoginDelegate where Self: UIApplicationDelegate {
	
	/// Helper method to configure a Salesforce instance
	/// - Paramater consumerKey: "Consumer Key" from Connected App
	/// - Parameter callbackURL: "Callback URL" from Connected App
	/// - Parameter loginHost: Host to which users will be directed if authentication is necessary. Defaults to "login.salesforce.com"
	/// - Parameter userID: User's record ID. Used for multi-user switching
	/// - Parameter orgID: User's org ID. Used for multi-user switching
	/// - Parameter version: version of the Salesforce API
    /// - Parameter extraUrl: add extra path to login url
	/// - Returns: configured instance of Salesforce
    public func configureSalesforce(consumerKey: String, callbackURL: URL, loginHost: String = ConnectedApp.defaultLoginHost, userID: String = ConnectedApp.defaultUserID, orgID: String = ConnectedApp.defaultOrgID, version: String = Salesforce.defaultVersion, extraUrl: String) -> Salesforce {
        let connectedApp = ConnectedApp(consumerKey: consumerKey, callbackURL: callbackURL, loginDelegate: self, loginHost: loginHost, userID: userID, orgID: orgID, extraUrl: extraUrl)
		return Salesforce(connectedApp: connectedApp, version: version)
	}
}
