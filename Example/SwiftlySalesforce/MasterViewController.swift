//
//  MasterViewController.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import UIKit
import Alamofire
import SwiftlySalesforce
import SafariServices

class MasterViewController: UITableViewController {

	@IBOutlet weak var toggleLogInButton: UIBarButtonItem!
	@IBOutlet weak var statusLabel: UILabel!
	
	var firstAppearance = true

	var tasks: [Task]? {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		AuthenticationManager.sharedInstance.loginDelegate = self
		AuthenticationManager.sharedInstance.logoutDelegate = self
		refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
	}
	
	override func viewWillAppear(animated: Bool) {
		
		super.viewWillAppear(animated)
		
		// Listen for AuthenticationManager notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAuthenticationManagerNotifications:", name: AuthenticationManager.AuthenticationSucceeded, object: AuthenticationManager.sharedInstance)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAuthenticationManagerNotifications:", name: AuthenticationManager.AuthorizationRevoked, object: AuthenticationManager.sharedInstance)

		toggleLogInButton.title = AuthenticationManager.sharedInstance.credentials == nil ? "Log In" : "Log Out"
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if firstAppearance {
			firstAppearance = false
			loadData()
		}
		tableView.reloadData()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	func loadData() {
		
		guard let credentials = AuthenticationManager.sharedInstance.credentials else {
			AuthenticationManager.sharedInstance.authenticate()
			return
		}
		
		statusLabel.text = "Loading tasks"
		let soql = "SELECT Id,Subject,Priority,Status,IsHighPriority,CreatedDate,ActivityDate,WhatId,What.Type,What.Name FROM Task WHERE OwnerId = '\(credentials.userID)' ORDER BY CreatedDate DESC"
		let req = SalesforceAPI.Query(soql: soql).endpoint(credentials: credentials)
		Alamofire.request(req)
			.validate()
			.salesforceResponse {
				
				[unowned self]
				(response) -> Void in
				
				switch response.result {
				case .Failure(let error):
					if error.isAuthenticationRequiredError() {
						AuthenticationManager.sharedInstance.authenticate()
						NSLog("Error: %@", error.description)
					}
					else {
						self.statusLabel.text = error.description
					}
				case .Success(let value):
					if let dict = value as? [String: AnyObject], let records = dict["records"] as? [[String: AnyObject]] {
						self.tasks = [Task]()
						for record in records {
							self.tasks?.append(Task(dictionary: record))
						}
						self.statusLabel.text = "\(self.tasks?.count ?? 0) tasks"
						self.tableView.reloadData()
					}
				}
				
				self.refreshControl?.endRefreshing()
			}
	}
	
	@objc func handleAuthenticationManagerNotifications(notification: NSNotification) {
		self.tasks = nil
		if let _ = AuthenticationManager.sharedInstance.credentials {
			toggleLogInButton.title = "Log Out"
			loadData()
		}
		else {
			toggleLogInButton.title = "Log In"
		}
	}
	
	func handleRefresh(refreshControl: UIRefreshControl) {
		loadData()
	}
	
	@IBAction func toggleLogIn(sender: AnyObject) {
		if let _ = AuthenticationManager.sharedInstance.credentials {
			statusLabel.text = "Logging out..."
			AuthenticationManager.sharedInstance.revokeAuthorization()
		}
		else {
			statusLabel.text = "Please wait while I authenticate..."
			AuthenticationManager.sharedInstance.authenticate()
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let destinationVC = segue.destinationViewController as? DetailViewController,
			let cell = sender as? UITableViewCell,
			let indexPath = tableView.indexPathForCell(cell),
			let task = tasks?[indexPath.row] {
			
			destinationVC.task = task
			destinationVC.title = task.subject ?? ""
		}
	}
}


// MARK: - Extension
extension MasterViewController {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tasks?.count ?? 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("DataCell")!
		if let task = self.tasks?[indexPath.row], let subject = task.subject, let status = task.status  {
			cell.textLabel?.text = "\(subject) (Status: \(status))"
			cell.detailTextLabel?.text = task.whatName
		}
		return cell
	}
}


// MARK: - Extension
extension MasterViewController: SFSafariViewControllerDelegate {
	
	func safariViewControllerDidFinish(controller: SFSafariViewController) {
		// Called if "Done" button clicked on Safari, i.e. user canceled login
		statusLabel.text = "Please log in to Salesforce"
		AuthenticationManager.sharedInstance.loginCanceled()
	}
}


// MARK: - Extension
extension MasterViewController: LoginDelegate {
	
	func loginWithURL(URL: NSURL) {
		guard self.presentedViewController == nil else {
			// Already presenting
			return
		}
		let safari = SFSafariViewController(URL: URL, entersReaderIfAvailable: false)
		safari.delegate = self
		presentViewController(safari, animated: true, completion: nil)
	}
	
	func loginCompleted() {
		dismissViewControllerAnimated(true, completion: nil)
		loadData()
	}
}


// MARK: - Extension
extension MasterViewController: LogoutDelegate {
	
	func logoutWithURL(URL: NSURL, startURL: NSURL) {
		
		guard presentedViewController == nil else {
			// Already showing a login view controller
			return
		}
		
		// Navigate to logout URL in order to clear the Salesforce UI session
		let safari = SFSafariViewController(URL: URL, entersReaderIfAvailable: false)
		safari.delegate = self
		presentViewController(safari, animated: true) {
			
			[unowned self]
			() -> Void in
			
			// Immediately go to start URL (usually the login URL)
			self.dismissViewControllerAnimated(false) {
				
				() -> Void in
				
				let safari = SFSafariViewController(URL: startURL, entersReaderIfAvailable: false)
				safari.delegate = self
				self.presentViewController(safari, animated: false, completion: nil)
			}
		}
	}
}
