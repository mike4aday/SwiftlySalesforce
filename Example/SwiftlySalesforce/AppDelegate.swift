//
//  AppDelegate.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.

import UIKit
import SwiftlySalesforce
import UserNotifications

// Global Salesforce variable - in your real-world app
// you could 'inject' it into view controllers instead
var salesforce: Salesforce!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {//, UNUserNotificationCenterDelegate, LoginDelegate {

	let consumerKey = "3MVG91ftikjGaMd_SSivaqQgkiguvTQSOZIWjqkAIkqFwbKfS6RHNjbI28Lvkvigc5KOJWsaFJCxpZvfAMA4Q"
	let callbackURL = URL(string: "taskforce://authorized")!

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		salesforce = try! Salesforce(consumerKey: consumerKey, callbackURL: callbackURL)
		return true
	}
}
