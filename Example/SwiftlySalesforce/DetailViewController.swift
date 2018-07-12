//
//  DetailViewController.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.

import Foundation
import UIKit
import SwiftlySalesforce

final class DetailViewController: UITableViewController {
	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var infoLabel: UILabel!
	
	public var statuses: [String] = Array<String>()
	public var onSave: ((Task) -> ())!
	public var task: Task? {
		didSet {
			selectedStatus = task?.status
		}
	}
	public var selectedStatus: String? {
		didSet {
			if let currentStatus = task?.status, let saveButton = self.saveButton, let infoLabel = self.infoLabel {
				saveButton.isEnabled = currentStatus == selectedStatus ? false : true
				infoLabel.text = currentStatus == selectedStatus ? "Select task status" : "Don't forget to press 'Save'!"
			}
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl?.addTarget(self, action: #selector(DetailViewController.handleRefresh), for: UIControlEvents.valueChanged)
		loadData()
	}
	
	/// Asynchronously load set of possible values for Task status
	func loadData() {
		
		infoLabel.text = "Loading task statuses..."
		
		first { () -> Promise<QueryResult<SObject>> in 
			salesforce.query(soql: "SELECT MasterLabel FROM TaskStatus ORDER BY SortOrder")
		}.done { (queryResult) in
			self.statuses = queryResult.records.compactMap { $0.string(forField: "MasterLabel") }
		}.ensure {
			self.infoLabel.text = "Select task status"
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
		}.catch { (error) -> () in
			self.alert(title: "Error!", error: error)
		}
	}
	
	// Asynchronously save updated Task record
	func save() {
		
		guard let task = self.task, let selectedStatus = self.selectedStatus, selectedStatus != task.status else {
			return
		}
		
		infoLabel.text = "Saving changes..."
		
		let recordUpdate: [String: Encodable?] = ["Status" : selectedStatus]
		salesforce.update(type: "Task", id: task.id, fields: recordUpdate).done {
			self.alert(title: "Success!", message: "Updated task status to \(selectedStatus)")
			self.task?.status = selectedStatus
			self.saveButton.isEnabled = false
			self.onSave(task)
		}.ensure {
			self.infoLabel.text = "Select task status"
			self.refreshControl?.endRefreshing()
		}.catch { error in
			self.alert(title: "Error!", error: error)
		}
	}
	
	@objc func handleRefresh(refreshControl: UIRefreshControl) {
		loadData()
	}
	
	@IBAction func saveButtonPressed(sender: AnyObject) {
		save()
	}
}


// MARK: - Extension
extension DetailViewController {
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.statuses.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell")!
		let status = statuses[indexPath.row]
		cell.textLabel?.text = status
		cell.accessoryType = (status == selectedStatus) ? .checkmark : .none
		return cell
	}
	
	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedStatus = statuses[indexPath.row]
		tableView.reloadData()
	}
}
