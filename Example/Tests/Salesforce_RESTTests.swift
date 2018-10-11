//
//  Salesforce_RESTTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce
import PromiseKit

class Salesforce_RESTTests: XCTestCase {
    
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let data = TestUtils.shared.read(fileName: "Configuration")!
		let config = try! JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Salesforce.Configuration.self, from: data)
		salesforce = Salesforce(configuration: config)
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testIdentity() {
		
		let exp = expectation(description: "Fetch identity")
		
		firstly { () -> Promise<Identity> in
			salesforce.identity()
		}.done { identity in
			debugPrint("User ID: \(identity.userID)")
			debugPrint("User Name: \(identity.username)")
			debugPrint("Last Modified Date: \(identity.lastModifiedDate)")
		}.catch {
			XCTFail($0.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testLimits() {
		
		let exp = expectation(description: "Fetch limits")
		
		firstly { () -> Promise<[String: Limit]> in
			salesforce.limits()
		}.done { limits in
			XCTAssertTrue(limits.count > 0)
		}.catch {
			XCTFail($0.localizedDescription)
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testOrganization() {
		
		let exp = expectation(description: "Fetch organization object")
		
		firstly { () -> Promise<Organization> in
			salesforce.organization()
		}.done { org in
			XCTAssertTrue(org.createdDate < Date())
		}.catch {
			XCTFail("\($0)")
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
	func testFetchImageByURL() {
		
		let exp = expectation(description: "Fetch image by URL")
		
		firstly { () -> Promise<Identity> in
			salesforce.identity()
		}.then { identity -> Promise<UIImage> in
			self.salesforce.fetchImage(url: identity.thumbnailURL!)
		}.done { image in
			// Done
		}.catch {
			XCTFail("\($0)")
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
	
/*
TODO: why does this fail with status code 404 when the image is present?
	func testFetchImageByPath() {
		
		struct Account: Decodable {
			let Id: String
			let Name: String
			let PhotoUrl: String?
		}
		
		let exp = expectation(description: "Fetch image by relative path")
		
		firstly { () -> Promise<QueryResult<Account>> in
			salesforce.query(soql: "SELECT Id,Name,PhotoUrl FROM Account WHERE PhotoUrl != NULL")
		}.then { queryResult -> Promise<UIImage> in
			let path = queryResult.records[0].PhotoUrl!
			self.salesforce.fetchImage(path: path)
		}.done { image in
			// Done
		}.catch {
			XCTFail("\($0)")
		}.finally {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 600, handler: nil)
	}
*/
}
