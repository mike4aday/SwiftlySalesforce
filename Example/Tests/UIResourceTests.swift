//
//  UIResourceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class UIResourceTests: XCTestCase {
    
	var auth: Authorization!
	
	override func setUp() {
		super.setUp()
		let accessToken = "ACCESS_TOKEN"
		let refreshToken = "REFRESH_TOKEN"
		let identityURL = URL(string: "https://login.salesforce.com/id/00Di0000000XXX3EAI/005i00000016PdaAAE")!
		let instanceURL = URL(string: "https://na15.salesforce.com")!
		auth = Authorization(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: refreshToken, issuedAt: 123)
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testRecords() {
	
		let recordIDs = ["001BBB","001AAA"]
		let childRelationships = ["Account.Contacts", "Account.Opportunities"]
		let formFactor = "Medium"
		let layoutTypes = ["Compact","Full"]
		let modes = ["Create","Edit"]
		let optionalFields = ["BillingCity","ShippingCity"]
		let pageSize = 5
		let version = "99.0"
		let res = UIResource.records(recordIds: recordIDs, childRelationships: childRelationships, formFactor: formFactor, layoutTypes: layoutTypes, modes: modes, optionalFields: optionalFields, pageSize: pageSize, version: version)
		let req = try! res.asURLRequest(with: auth)
		let comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)
		
		XCTAssertEqual(req.url!.path, "/services/data/v99.0/ui-api/record-ui/001BBB,001AAA")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "childRelationships" }.first!.value, "Account.Contacts,Account.Opportunities")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "formFactor" }.first!.value, "Medium")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "layoutTypes" }.first!.value, "Compact,Full")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "modes" }.first!.value, "Create,Edit")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "optionalFields" }.first!.value, "BillingCity,ShippingCity") 
	}
	
	func testDefaultsForCloning() {
		
		let recordID = "001123"
		let formFactor = "Medium"
		let optionalFields = ["BillingCity","ShippingCity"]
		let recordTypeID = "00N123"
		let version = "99.1"
		let res = UIResource.defaultsForCloning(recordId: recordID, formFactor: formFactor, optionalFields: optionalFields, recordTypeId: recordTypeID, version: version)
		let req = try! res.asURLRequest(with: auth)
		let comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)
		
		XCTAssertEqual(req.url!.path, "/services/data/v99.1/ui-api/record-defaults/clone/001123")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "formFactor" }.first!.value, "Medium")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "optionalFields" }.first!.value, "BillingCity,ShippingCity")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "recordTypeId" }.first!.value, "00N123")
	}
	
	func testDefaultsForCreating() {
		
		let type = "Account"
		let formFactor = "Medium"
		let optionalFields = ["BillingCity","ShippingCity"]
		let recordTypeID = "00N123"
		let version = "99.1"
		let res = UIResource.defaultsForCreating(objectApiName: type, formFactor: formFactor, optionalFields: optionalFields, recordTypeId: recordTypeID, version: version)
		let req = try! res.asURLRequest(with: auth)
		let comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)
		
		XCTAssertEqual(req.url!.path, "/services/data/v99.1/ui-api/record-defaults/create/Account")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "formFactor" }.first!.value, "Medium")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "optionalFields" }.first!.value, "BillingCity,ShippingCity")
		XCTAssertEqual(comps!.queryItems!.filter{ $0.name == "recordTypeId" }.first!.value, "00N123")
	}
}
