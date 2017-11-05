//
//  AppDelegate.swift
//  Example for SwiftlySalesforce
//
//  Created by Michael Epstein on 10/03/2016.
//  Copyright (c) 2016 Michael Epstein. All rights reserved.
//

import UIKit
import SwiftlySalesforce
import UserNotifications

var salesforce: Salesforce!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, LoginDelegate {

	let consumerKey = "<YOUR CONNECTED APP'S CONSUMER KEY HERE>"
	let callbackURL = URL(string: "<YOUR CONNECTED APP'S REDIRECT URL HERE>")!
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		salesforce = configureSalesforce(consumerKey: consumerKey, callbackURL: callbackURL)
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		handleCallbackURL(url, for: salesforce.connectedApp)
		return true
	}
}
