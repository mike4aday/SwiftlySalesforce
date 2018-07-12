//
//  MasterViewController.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.

import UIKit
import SwiftlySalesforce
import PromiseKit

final class MasterViewController: UITableViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var photoView: UIImageView!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var logoutButton: UIBarButtonItem!
	@IBOutlet weak var noDataView: UIView!
	
	// In-memory list of Tasks. In real-world app, you might
	// store them in local datastore, e.g. Realm.
	private var tasks: [Task] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh), for: UIControlEvents.valueChanged)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? DetailViewController,
			let cell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: cell) {
			let task = tasks[indexPath.row]
			let onSave = { (task: Task) -> () in
				self.tasks[indexPath.row] = task
				self.tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			destinationVC.task = task
			destinationVC.title = task.subject ?? ""
			destinationVC.onSave = onSave
		}
	}
	
	@IBAction func logoutButtonPressed(sender: AnyObject) {
		salesforce.revoke().done {
			debugPrint("Access token revoked.")
		}.ensure {
			self.tasks.removeAll()
			self.photoView.image = nil
			self.nameLabel.text = "Welcome"
			self.statusLabel.text = "Pull to login or refresh."
			self.tableView.reloadData()
		}.catch {
			debugPrint("Unable to revoke user access token: \($0.localizedDescription)")
		}
	}
	
	func loadUserInfo() {
		salesforce.identity().compactMap { (identity) -> URL? in
			self.nameLabel.text = identity.displayName
			return identity.photoURL
		}.then { (url) -> Promise<UIImage> in
			salesforce.fetchImage(url: url)
		}.done { image -> () in
			self.photoView.image = image
		}.catch {
			debugPrint("Unable to load user photo! (\($0.localizedDescription))")
		}
	}
	
	/// Asynchronously load current user's tasks
	func loadTasks() {
		
		statusLabel.text = "Loading tasks..."
		self.refreshControl?.isEnabled = false
		
		firstly { () -> Promise<String> in
			if let userID = salesforce.userID {
				return Promise.value(userID)
			}
			else {
				return salesforce.identity().map { return $0.userID }
			}
		}.then { userID -> Promise<QueryResult<Task>> in
			let soql = """
				SELECT Id,CreatedDate,Subject,Status,IsHighPriority,What.Name
				FROM Task WHERE OwnerId = '\(userID)'
				ORDER BY CreatedDate DESC
			"""
			return salesforce.query(soql: soql)
		}.map { (queryResult) -> () in
			self.tasks = queryResult.records
		}.ensure {
			self.refreshControl?.endRefreshing()
			self.refreshControl?.isEnabled = true
			self.tableView.reloadData()
			self.statusLabel.text = "You have \(self.tasks.count) tasks. Pull to refresh."
			self.logoutButton.isEnabled = salesforce.accessToken != nil
		}.catch { (error) -> () in
			self.alert(title: "Error!", error: error)
		}
	}
	
	/// Refresh control handler
	@objc func handleRefresh(refreshControl: UIRefreshControl) {
		loadTasks()
		loadUserInfo()
	}
}


// MARK: - Extension
extension MasterViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if tasks.count > 0 {
			tableView.backgroundView = nil
			tableView.separatorStyle = .singleLine
			return 1
		}
		else {
			tableView.backgroundView = noDataView
			tableView.separatorStyle = .none
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell")!
		let task = tasks[indexPath.row]
		if let subject = task.subject, let status = task.status  {
			cell.textLabel?.text = subject
			cell.detailTextLabel?.text = status
		}
		return cell
	}
}

// MARK: - Extension
extension UIViewController {
	
	func alert(title: String, message: String) {
		if let presented = self.presentedViewController {
			presented.dismiss(animated: true) {
				self.alert(title: title, message: message)
			}
			return
		}
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func alert(title: String, error: Error) {
		debugPrint(error.localizedDescription)
		return alert(title: title, message: error.localizedDescription)
	}
	
}
