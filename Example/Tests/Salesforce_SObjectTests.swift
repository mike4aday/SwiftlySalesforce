//
//  Salesforce_SObjectTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_SObjectTests: XCTestCase {
	
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

	func testThatItRetrieves() {
		
		let exp = expectation(description: "Retrieves as SObject and custom decodable")
		
		struct MyAccount: Decodable {
			var Id: String
			var Name: String
			var BillingCountry: String
			var BillingCity: String
		}
		
		firstly { () -> Promise<String> in
			
			// Insert test record
			salesforce.insert(type: "Account", fields: ["Name":"XYZ", "BillingCountry": "Canada", "BillingCity": "Toronto"])
		
		}.then { (id) -> Promise<SObject> in
			
			// Retrieve as SObject
			self.salesforce.retrieve(type: "Account", id: id)
			
		}.then { (record) -> Promise<MyAccount> in
			
			// Note: these assertions could fail in an org that
			// changes data on/after insert...
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.string(forField: "BillingCountry"), "Canada")
			XCTAssertEqual(record.string(forField: "BillingCity"), "Toronto")
			
			// Retrieve as custom Decodable
			return self.salesforce.retrieve(type: "Account", id: record.id!)
		
		}.then { (record) -> Promise<Void> in
		
			XCTAssertTrue(record.Id.starts(with: "001"))
			XCTAssertEqual(record.BillingCountry, "Canada")
			XCTAssertEqual(record.BillingCity, "Toronto")
			
			// Delete record in Salesforce
			return self.salesforce.delete(type: "Account", id: record.Id)
	
		}.catch { error in
		
			XCTFail(error.localizedDescription)
		
		}.finally {
		
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItInserts() {
		
		let exp = expectation(description: "Inserts as field dictionary, SObject and custom encodable")
		
		struct MyAccount: Encodable {
			var Name: String
			var BillingCountry: String
			var BillingCity: String
		}
		
		firstly { () -> Promise<String> in
			
			// Insert test record with field dictionary
			salesforce.insert(type: "Account", fields: ["Name":"XYZ", "BillingCountry": "Canada", "BillingCity": "Toronto"])
			
		}.then { (id) -> Promise<SObject> in
			
			// Retrieve as SObject
			self.salesforce.retrieve(type: "Account", id: id)
			
		}.then { (record: SObject) -> Promise<Void> in
			
			// Note: these assertions could fail in an org that
			// changes data on/after insert...
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.value(forField: "Name"), "XYZ")
			XCTAssertEqual(record.string(forField: "BillingCountry"), "Canada")
			XCTAssertEqual(record.string(forField: "BillingCity"), "Toronto")
			
			// Delete the test record
			return self.salesforce.delete(record: record)
			
		}.then { () -> Promise<String> in
			
			// Insert as SObject
			var record = SObject(type: "Account")
			record.setValue("XYZ", forField: "Name")
			record.setValue("Canada", forField: "BillingCountry")
			record.setValue("Toronto", forField: "BillingCity")
			return self.salesforce.insert(record: record)
			
		}.then { (id) -> Promise<SObject> in
			
			// Retrieve as SObject
			return self.salesforce.retrieve(type: "Account", id: id)
			
		}.then { (record: SObject) -> Promise<Void> in
			
			// Note: these assertions could fail in an org that
			// changes data on/after insert...
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.value(forField: "Name"), "XYZ")
			XCTAssertEqual(record.string(forField: "BillingCountry"), "Canada")
			XCTAssertEqual(record.string(forField: "BillingCity"), "Toronto")
			
			// Delete the test record
			return self.salesforce.delete(record: record)
			
		}.then { () -> Promise<String> in
			
			// Insert as custom encodable
			let record = MyAccount(Name: "XYZ", BillingCountry: "Canada", BillingCity: "Toronto")
			return self.salesforce.insert(type: "Account", record: record)
			
		}.then { (id) -> Promise<SObject> in
			
			// Retrieve as SObject
			return self.salesforce.retrieve(type: "Account", id: id)
			
		}.then { (record) -> Promise<Void> in
			
			// Note: these assertions could fail in an org that
			// changes data on/after insert...
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.value(forField: "Name"), "XYZ")
			XCTAssertEqual(record.string(forField: "BillingCountry"), "Canada")
			XCTAssertEqual(record.string(forField: "BillingCity"), "Toronto")
			
			// Delete test record
			return self.salesforce.delete(record: record)
				
		}.catch { error in
			
			XCTFail(error.localizedDescription)
			
		}.finally {
			
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItInsertsUpdatesRetrievesAndDeletes() {
		
		let exp = expectation(description: "Inserts, updates, retrieves and deletes 1 account")
		
		firstly { () -> Promise<String> in
		
			// Insert
			salesforce.insert(type: "Account", fields: ["Name":"Really Large Corp., Inc.", "ShippingCountry": "Canada"])
		
		}.then { (id) -> Promise<SObject> in
			
			// Retrieve
			self.salesforce.retrieve(type: "Account", id: id)
		
		}.then { (record) -> Promise<String> in
			
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.string(forField: "ShippingCountry"), "Canada")
			XCTAssertNil(record.string(forField: "ShippingCity"))
			
			// Update
			return self.salesforce.update(type: "Account", id: record.id!, fields: ["ShippingCity": "Milan", "ShippingCountry": "Italy"]).map { record.id! }
		
		}.then { (id) -> Promise<SObject> in
			
			// Retrieve again
			return self.salesforce.retrieve(type: "Account", id: id)
		
		}.then { (record) -> Promise<Void> in
		
			XCTAssertTrue(record.id!.starts(with: "001"))
			XCTAssertEqual(record.string(forField: "ShippingCountry"), "Italy")
			XCTAssertEqual(record.string(forField: "ShippingCity"), "Milan")
		
			// Delete
			return self.salesforce.delete(type: "Account", id: record.id!)

		}.catch { error in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItDescribes() {
		
		let exp = expectation(description: "Describes Account and Contact")

		firstly { () -> Promise<[ObjectDescription]> in
			
			salesforce.describe(types: ["Account", "Contact"], options: [])
			
		}.done { (descriptions: [ObjectDescription]) -> () in
		
			let accountMetadata = descriptions[0]
			let contactMetadata = descriptions[1]
			
			XCTAssertEqual(accountMetadata.name, "Account")
			XCTAssertFalse(accountMetadata.isCustom)
			XCTAssertEqual(contactMetadata.name, "Contact")
			XCTAssertFalse(contactMetadata.isCustom)
		
		}.catch { error in
		
			XCTFail(error.localizedDescription)
		
		}.finally {
		
			exp.fulfill()
		
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItFailsToDescribe() {
		
		let exp = expectation(description: "Doesn't describe fake custom object")
		
		firstly { () -> Promise<ObjectDescription> in
			salesforce.describe(type: UUID().uuidString)
		}.done { description in
			XCTFail("Shouldn't have retrieved fake object")
		}.catch {error in
			guard case let Salesforce.Error.resourceError(statusCode, _, _, _) = error, statusCode == 404 else {
				XCTFail(error.localizedDescription)
				return
			}
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testThatItDescribesAll() {
		
		let exp = expectation(description: "Describes Account and Contact")
		
		firstly { () -> Promise<[ObjectDescription]> in
			salesforce.describeAll()
		}.done { (descriptions: [ObjectDescription]) -> () in
			XCTAssertNotNil(descriptions.filter { $0.name == "Account" }.first)
		}.catch { error in
			XCTFail(error.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
}
