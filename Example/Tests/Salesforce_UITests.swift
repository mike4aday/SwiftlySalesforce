//
//  Salesforce_UITests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 7/6/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
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
		}.then { (id) -> Promise<Data> in
			// Get record
			let childRelationships = ["Account.Contacts", "Account.Opportunities"]
			let formFactor = Salesforce.FormFactor.medium
			let layoutTypes = [Salesforce.LayoutType.compact,Salesforce.LayoutType.full]
			let modes = [Salesforce.Mode.create,Salesforce.Mode.edit]
			return self.salesforce.recordsAndMetadata(recordIds: [id], childRelationships: childRelationships, formFactor: formFactor, layoutTypes: layoutTypes, modes: modes)
		}.done { result in
			return
			//return salesforce.delete(type: "Account", id: <#T##String#>)
		}.catch { error in
			XCTFail("\(error)")
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
}
