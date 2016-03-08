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
import PromiseKit

class MasterViewController: UITableViewController {

	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var logoutButton: UIBarButtonItem!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
		loadData(refresh: true)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		loadData(refresh: false)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let destinationVC = segue.destinationViewController as? DetailViewController,
			let cell = sender as? UITableViewCell,
			let indexPath = tableView.indexPathForCell(cell),
			let task = TaskStore.sharedInstance.cache?[indexPath.row] {
				destinationVC.task = task
				destinationVC.title = task.subject ?? ""
		}
	}
	
	@IBAction func logoutButtonPressed(sender: AnyObject) {
		if let app = UIApplication.sharedApplication().delegate as? LoginViewPresentable {
			app.logOut().then {
				() -> () in
				TaskStore.sharedInstance.clear()
				self.tableView.reloadData()
				return
			}
		}
	}
	
	/// Asynchronously load current user's tasks
	func loadData(refresh refresh: Bool = false) {
		
		statusLabel.text = "Loading tasks"
		
		firstly {
			TaskStore.sharedInstance.getTasks(refresh: refresh)
		}.always {
			() -> () in
			self.refreshControl?.endRefreshing()
			self.statusLabel.text = "You have \(TaskStore.sharedInstance.cache?.count ?? 0) tasks. Pull to refresh."
			self.tableView.reloadData()
			self.logoutButton.enabled = OAuth2Manager.sharedInstance.credentials != nil
		}.error {
			// Handle any errors
			(error) -> () in
			self.alertWithTitle("Error!", error: error)
		}
	}
	
	/// Refresh control handler
	func handleRefresh(refreshControl: UIRefreshControl) {
		loadData(refresh: true)
	}
}


// MARK: - Extension
extension MasterViewController {
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return TaskStore.sharedInstance.cache?.count ?? 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("DataCell")!
		if let task = TaskStore.sharedInstance.cache?[indexPath.row], let subject = task.subject, let status = task.status  {
			cell.textLabel?.text = "\(subject) (Status: \(status))"
			cell.detailTextLabel?.text = task.whatName
		}
		return cell
	}
}

// MARK: - Extension
extension UIViewController {

	func alertWithTitle(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func alertWithTitle(title: String, error: ErrorType) {
		return alertWithTitle(title, message: "\(error)")
	}

}
