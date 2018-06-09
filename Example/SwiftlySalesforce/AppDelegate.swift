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
class AppDelegate: UIResponder, UIApplicationDelegate {//, UNUserNotificationCenterDelegate, LoginDelegate {

	let consumerKey = "3MVG91ftikjGaMd_SSivaqQgkiguvTQSOZIWjqkAIkqFwbKfS6RHNjbI28Lvkvigc5KOJWsaFJCxpZvfAMA4Q"
	let callbackURL = URL(string: "taskforce://authorized")!

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let config = try! Salesforce.Configuration(consumerKey: consumerKey, callbackURL: callbackURL)
		salesforce = Salesforce(configuration: config)
		if let navVC = window?.rootViewController as? UINavigationController, let topVC = navVC.topViewController as? TaskTableViewController {
			topVC.salesforce = salesforce
		}
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
	//	handleCallbackURL(url, for: salesforce.connectedApp)
		return true
	}
}
