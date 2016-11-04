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
	let consumerKey = "3MVG91ftikjGaM__SSivaqQgkik_rz_GSRYmFpDR6yDaUrEfpC0vKqisPMY1ilyH78G9Ocpl2p7IJuqRk07nQ"
	let redirectURL = URL(string: "taskforce://authorized")!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		configureSalesforce(consumerKey: consumerKey, redirectURL: redirectURL)
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		handleRedirectURL(redirectURL: url as URL)
		return true
	}
}
