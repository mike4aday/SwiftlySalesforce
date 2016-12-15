//
//  AppDelegate.swift
//  Example for SwiftlySalesforce
//
//  Created by Michael Epstein on 10/03/2016.
//  Copyright (c) 2016 Michael Epstein. All rights reserved.
//

import UIKit
import SwiftlySalesforce

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate {

	var window: UIWindow?
	
	/// Salesforce Connected App properties
	let consumerKey = "<YOUR SALESFORCE CONNECTED APP'S CONSUMER KEY>" // Replace with your own
	let redirectURL = URL(string: "scheme://redirect")! // Replace with your own

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		configureSalesforce(consumerKey: consumerKey, redirectURL: redirectURL)
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		handleRedirectURL(url: url)
		return true
	}
}
