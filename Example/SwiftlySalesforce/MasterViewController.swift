//
//  MasterViewController.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.

import UIKit
import SwiftlySalesforce

final class MasterViewController: UITableViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var photoView: UIImageView!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var logoutButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh), for: UIControlEvents.valueChanged)
		loadData(refresh: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadData(refresh: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? DetailViewController,
			let cell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: cell),
			let task = TaskStore.shared.cache?[indexPath.row] {
			destinationVC.task = task
			destinationVC.title = task.subject ?? ""
		}
	}
	
	@IBAction func logoutButtonPressed(sender: AnyObject) {
		if let app = UIApplication.shared.delegate as? LoginDelegate {
			app.logout(from: salesforce.connectedApp).then {
				() -> () in
				TaskStore.shared.clear()
				self.photoView.image = nil
				self.nameLabel.text = nil
				self.tableView.reloadData()
				return
			}.catch {
				error in
				debugPrint(error)
			}
		}
	}
	
	/// Asynchronously load current user's tasks
	func loadData(refresh: Bool = false) {
		
		statusLabel.text = "Loading tasks..."
		self.refreshControl?.isEnabled = false
		
		/// "first" is an optional way to make chained calls look better...
		first {
			// Note we're running 2 tasks in parallel here...
			fulfill(TaskStore.shared.getTasks(refresh: refresh), salesforce.identity())
		}.then {
			(_, identity) -> Promise<UIImage> in
			self.nameLabel.text = identity.displayName
			if let photoURL = identity.photoURL {
				return salesforce.fetchImage(url: photoURL)
			}
			else {
				throw TaskForceError.generic(code: -231, message: "No image URL!")
			}
		}.then {
			image in
			self.photoView.image = image
		}.always {
			self.refreshControl?.endRefreshing()
			self.refreshControl?.isEnabled = true
			self.tableView.reloadData()
			self.statusLabel.text = "You have \(TaskStore.shared.cache?.count ?? 0) tasks. Pull to refresh."
			self.logoutButton.isEnabled = salesforce.connectedApp.accessToken != nil
		}.catch {
			// Handle any errors
			(error) -> () in
			self.alert(title: "Error!", error: error)
		}
	}
	
	/// Refresh control handler
	func handleRefresh(refreshControl: UIRefreshControl) {
		loadData(refresh: true)
	}
}


// MARK: - Extension
extension MasterViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return TaskStore.shared.cache?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell")!
		if let task = TaskStore.shared.cache?[indexPath.row], let subject = task.subject, let status = task.status  {
			cell.textLabel?.text = "\(subject) (Status: \(status))"
			cell.detailTextLabel?.text = task.whatName
		}
		return cell
	}
}

// MARK: - Extension
extension UIViewController {
	
	func alert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func alert(title: String, error: Error) {
		return alert(title: title, message: "\(error)")
	}
	
}
