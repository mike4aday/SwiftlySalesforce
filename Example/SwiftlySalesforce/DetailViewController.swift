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
	public var task: Task? {
		didSet {
			selectedStatus = task?.status
		}
	}
	public var statuses: [String]?
	public var selectedStatus: String? {
		didSet {
			guard let currentStatus = task?.status, let saveButton = self.saveButton, let infoLabel = self.infoLabel else {
				return
			}
			saveButton.enabled = currentStatus == selectedStatus ? false : true
			infoLabel.text = currentStatus == selectedStatus ? "Select task status" : "Don't forget to press 'Save'!"
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		loadData()
	}
	
	func loadData() {
		
		guard let credentials = AuthenticationManager.sharedInstance.credentials else {
			AuthenticationManager.sharedInstance.authenticate()
			return
		}
		
		infoLabel.text = "Loading task statuses..."
		
		let soql = "SELECT MasterLabel FROM TaskStatus ORDER BY SortOrder"
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
					}
					else {
						self.infoLabel.text = error.description
					}
				case .Success(let value):
					if let dict = value as? [String: AnyObject], let records = dict["records"] as? [[String: AnyObject]] {
						self.statuses = [String]()
						for record in records {
							if let label = record["MasterLabel"] as? String {
								self.statuses?.append(label)
							}
						}
						self.infoLabel.text = "Select task status"
						self.tableView.reloadData()
					}
				}
				
				self.refreshControl?.endRefreshing()
		}
	}
	
	func save() {
		
		guard let credentials = AuthenticationManager.sharedInstance.credentials else {
			AuthenticationManager.sharedInstance.authenticate()
			return
		}
		
		guard let task = self.task, let id = task.id, let selectedStatus = self.selectedStatus where selectedStatus != task.status else {
			return
		}
		
		infoLabel.text = "Saving changes..."
		
		let recordUpdate: [String: AnyObject] = ["Status" : selectedStatus ]
		let req = SalesforceAPI.UpdateRecord(type: "Task", id: id, fields: recordUpdate).endpoint(credentials: credentials)
		Alamofire.request(req)
			.validate()
			.salesforceResponse {
				
				[unowned self]
				(response) -> Void in
				
				switch response.result {
				case .Success:
					self.infoLabel.text = "Changes saved"
					self.tableView.reloadData()
					task.status = selectedStatus
					self.saveButton.enabled = false
				case .Failure(let error):
					if error.isAuthenticationRequiredError() {
						AuthenticationManager.sharedInstance.authenticate()
					}
					else {
						self.infoLabel.text = error.description
					}
				}
				
				self.refreshControl?.endRefreshing()
		}

	}
	
	@IBAction func saveButtonPressed(sender: AnyObject) {
		save()
	}
}

extension DetailViewController {
	
	public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
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


