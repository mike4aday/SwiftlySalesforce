//
//  Salesforce_UITests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_UITests: XCTestCase {
    
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		salesforce = Salesforce(configuration: config)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
    
	func testThatItGetsRecordLayoutAndMetadata() {
		
		let exp = expectation(description: "Get record data and metadata")
		
		firstly { () -> Promise<String> in
			// Insert test Account record
			return salesforce.insert(type: "Account", fields: ["Name":"XYZ", "BillingCountry": "Canada", "BillingCity": "Toronto"])
		}.then { (id) -> Promise<(Data,String)> in
			// Get record
			let childRelationships = ["Account.Contacts", "Account.Opportunities"]
			let formFactor = Salesforce.FormFactor.medium
			let layoutTypes = [Salesforce.LayoutType.compact,Salesforce.LayoutType.full]
			let modes = [Salesforce.Mode.create,Salesforce.Mode.edit]
			return self.salesforce.recordsAndMetadata(recordIds: [id], childRelationships: childRelationships, formFactor: formFactor, layoutTypes: layoutTypes, modes: modes).map { (data: Data) -> (Data,String) in
				return (data, id)
			}
		}.then { (data,id) in
			return self.salesforce.delete(type: "Account", id: id)
		}.done { () -> () in
			// Done
		}.catch { error in
			XCTFail("\(error)")
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItGetsDefaultsForCloning() {
		
		let exp = expectation(description: "Get defaults for cloning record")
		
		firstly { () -> Promise<String> in
			// Insert test Account record
			return salesforce.insert(type: "Account", fields: ["Name":"XYZ", "BillingCountry": "Canada", "BillingCity": "Toronto"])
		}.then { (id) -> Promise<(Data,String)> in
			// Get defaults for cloning the inserted record
			let formFactor = Salesforce.FormFactor.medium
			let optionalFields = ["Account.BillingCity","Account.BillingCountry"]
			return self.salesforce.defaultsForCloning(recordId: id, formFactor: formFactor, optionalFields: optionalFields).map { (data: Data) -> (Data,String) in
				return (data, id)
			}
		}.then { (data,id) in
			// Delete record inserted earlier
			return self.salesforce.delete(type: "Account", id: id)
		}.done { () -> () in
			// Done
		}.catch { error in
			XCTFail("\(error)")
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItGetsDefaultsForCreating() {
		
		let exp = expectation(description: "Get defaults for creating record")
		
		firstly { () -> Promise<Data> in
				// Get defaults for creating
				let formFactor = Salesforce.FormFactor.medium
				let optionalFields = ["Account.BillingCity","Account.BillingCountry"]
				return salesforce.defaultsForCreating(objectApiName: "Account", formFactor: formFactor, optionalFields: optionalFields)
			}.done { (data) -> () in
				// Done
			}.catch { error in
				XCTFail("\(error)")
			}.finally {
				exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
}
