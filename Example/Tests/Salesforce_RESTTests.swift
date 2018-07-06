//
//  Salesforce_RESTTests.swift
//  SwiftlySalesforce_Tests
//
//  Created by Michael Epstein on 7/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
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
}
