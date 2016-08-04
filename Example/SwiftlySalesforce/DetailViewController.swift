//
//  DetailViewController.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import UIKit
import SwiftlySalesforce
import Alamofire

public class DetailViewController: UITableViewController {

	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var infoLabel: UILabel!
	
	public var statuses: [String]?
	public var task: Task? {
		didSet {
			selectedStatus = task?.status
		}
	}
	public var selectedStatus: String? {
		didSet {
			if let currentStatus = task?.status, let saveButton = self.saveButton, let infoLabel = self.infoLabel {
				saveButton.enabled = currentStatus == selectedStatus ? false : true
				infoLabel.text = currentStatus == selectedStatus ? "Select task status" : "Don't forget to press 'Save'!"
			}
		}
	}
	
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl?.addTarget(self, action: #selector(DetailViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
		loadData()
	}
	
	/// Asynchronously load set of possible values for Task status
	func loadData() {
		
		infoLabel.text = "Loading task statuses..."
		
		SalesforceAPI.Query(soql: "SELECT MasterLabel FROM TaskStatus ORDER BY SortOrder").request()
		.then {
			(result) -> () in
			if let records = result["records"] as? [[String: AnyObject]] {
				self.statuses = records.map { $0["MasterLabel"] as? String ?? "N/A" }
			}
		}.always {
			self.infoLabel.text = "Select task status"
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
		}.error {
			(error) -> () in
			self.alertWithTitle("Error!", error: error)
		}
	}

	// Asynchronously save updated Task record
	func save() {
		
		guard let task = self.task, let id = task.id, let selectedStatus = self.selectedStatus where selectedStatus != task.status else {
			return
		}
		
		infoLabel.text = "Saving changes..."
	
		let recordUpdate: [String: AnyObject] = ["Status" : selectedStatus]
		SalesforceAPI.UpdateRecord(type: "Task", id: id, fields: recordUpdate).request()
		.then {
			(_) -> () in
			self.alertWithTitle("Success!", message: "Updated task status to \(selectedStatus)")
		}.then {
			(_) -> () in
			self.task?.status = selectedStatus
			self.saveButton.enabled = false
		}.always {
			self.infoLabel.text = "Select task status"
			self.refreshControl?.endRefreshing()
		}
	}
	
	func handleRefresh(refreshControl: UIRefreshControl) {
		loadData()
	}
	
	@IBAction func saveButtonPressed(sender: AnyObject) {
		save()
	}
}


// MARK: - Extension
extension DetailViewController {
	
	public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.statuses?.count ?? 0
	}
	
	public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("DataCell")!
		if let status = statuses?[indexPath.row]  {
			cell.textLabel?.text = status
			cell.accessoryType = (status == selectedStatus) ? .Checkmark : .None
		}
		return cell
	}
	
	public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectedStatus = statuses?[indexPath.row]
		tableView.reloadData()
	}
}


