//
//  SObjectTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class SObjectTests: XCTestCase {
	
	let decoder = JSONDecoder(dateFormatter: .salesforceDateTimeFormatter)
	let encoder = JSONEncoder(dateFormatter: .salesforceDateTimeFormatter)
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
    
    func testThatItInitsSObject() {
		
		let data = TestUtils.shared.read(fileName: "MockAccount", ofType: "json")!
		guard let account = try? decoder.decode(SObject.self, from: data) else {
			XCTFail()
			return
		}
		
		XCTAssertEqual(account.id, "0011Y00002LZRxeQAH")
		XCTAssertEqual(account.id, account.string(forField: "Id"))
		XCTAssertEqual(account.type, "Account")
		XCTAssertEqual(account.url(forField: "Website")?.absoluteString, "https://www.megacorp.com")
		XCTAssertEqual(account.int(forField: "NumberOfEmployees"), 12345)
		XCTAssertEqual(account.double(forField: "AnnualRevenue"), 543210.00)
		XCTAssertEqual(account.float(forField: "AnnualRevenue"), 543210.0)
		XCTAssertNotNil(account.date(forField: "CreatedDate"))
		XCTAssertEqual(account.value(forField: "BillingCountry"), "US")
		XCTAssertEqual(account.address(forField: "BillingAddress")!.country, "US")
		XCTAssertNotNil(account.value(forField: "LastModifiedDate") as Date?)
		XCTAssertNil(account.value(forField: "LastReferencedDate") as Date?)
		XCTAssertEqual(account["Name"], "Megacorp, Inc.")
		XCTAssertEqual(account["Website"], URL(string: "https://www.megacorp.com")!)
		XCTAssertNotNil(account["PhotoUrl"] as String?)
		XCTAssertNil(account["Phone"] as String?)
    }
	
	func testThatItInitsAggregateResult() {
		
		let data = TestUtils.shared.read(fileName: "MockAggregateQueryResult", ofType: "json")!
		guard let results = try? decoder.decode(QueryResult<SObject>.self, from: data) else {
			XCTFail()
			return
		}
		XCTAssertEqual(results.records.count, 2)
		for sobj in results.records {
			XCTAssertEqual(sobj.type, "AggregateResult")
			XCTAssertNil(sobj.id)
		}
	}
	
	func testThatItEncodesAndDecodes() {
		
		var record = SObject(type: "Account")
		
		record.setValue("Mega Corp., Inc.", forField: "Name")
		record.setValue(URL(string: "https://www.mycompany.com")!, forField: "Website")
		record.setValue(Int(12345.5), forField: "NumberOfEmployees")
		record.setValue(Double(12345678.90), forField: "Revenue")
		record.setValue(nil, forField: "Type")
		record.setValue("60611", forField: "BillingPostalCode")
		record.setValue(Date(), forField: "CreatedDate")
		var dict = (try! JSONSerialization.jsonObject(with: encoder.encode(record), options: .allowFragments) as? [String: Any])!

		// "Re-hydrate"
		dict["attributes"] = ["url": "/services/data/v41.0/sobjects/Account/0011Y00002LZRxeQAH", "type": "Account"]
		let data = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
		let record2 = try! decoder.decode(SObject.self, from: data)
		
		XCTAssertEqual(record2.id, "0011Y00002LZRxeQAH")
		XCTAssertEqual(record2.url(forField: "Website"), URL(string: "https://www.mycompany.com")!)
		XCTAssertEqual(record2.int(forField: "NumberOfEmployees"), 12345)
		XCTAssertEqual(record2.double(forField: "Revenue"), 12345678.90)
		XCTAssertNil(record2.string(forField: "Type"))
		XCTAssertNil(record2["Type"] as String?)
		XCTAssertNil(record2.value(forField: "Type") as String?)
		XCTAssertEqual(record2.string(forField: "BillingPostalCode"), "60611")
		XCTAssertEqual(record2["BillingPostalCode"], "60611")
		XCTAssertEqual(record2.value(forField: "BillingPostalCode"), "60611")
		XCTAssertNotNil(record2.date(forField: "CreatedDate"))
		XCTAssertNil(record2.value(forField: "NOT_A_FIELD") as String?)
	}
	
	func testThatItMutates() {
		
		let data = TestUtils.shared.read(fileName: "MockAccount", ofType: "json")!
		guard var account = try? decoder.decode(SObject.self, from: data) else {
			XCTFail()
			return
		}
		
		account.setValue("Huge Corporation, Inc.", forField: "Name")
		account.setValue("Conglomerate", forField: "Type")
		account.setValue(nil, forField: "BillingPostalCode")
		account.setValue(Date(), forField: "LastViewedDate")
		account.setValue(1234.56, forField: "ShippingFees")
		account.setValue(1, forField: "NumberOfEmployees")
		account.setValue(URL(string: "https://www.corp.com")!, forField: "Website")
		account.setValue(false, forField: "Flag")
		account.setValue(Float(123456789.789), forField: "Rate")
		
		XCTAssertEqual(account["Name"], "Huge Corporation, Inc.")
		XCTAssertEqual(account["Type"], "Conglomerate")
		XCTAssertNil(account.string(forField: "BillingPostalCode"))
		XCTAssertNotNil(account.date(forField: "LastViewedDate"))
		XCTAssertEqual(account["ShippingFees"], 1234.56)
		XCTAssertEqual(account.url(forField: "Website"), URL(string: "https://www.corp.com")!)
		XCTAssertFalse(account.bool(forField: "Flag")!)
		XCTAssertEqual(account.float(forField: "Rate"), Float(123456789.789))
	}
	
	func testThatItInitsFromDictionary() {
		
		let dict: [String: Codable?] = [
			"Name" : "Tiny Biz, Inc.",
			"NumberOfEmployees" : 123,
			"LastModifiedDate" : Date(timeIntervalSince1970: 10000),
			"CEO" : nil,
			"TaxRate" : 0.05,
			"Website" : URL(string: "https://tiny.biz"),
			"BigCompany?" : false
		]
		let account = SObject(type: "Account", fields: dict)
		
		XCTAssertEqual(account["Name"], "Tiny Biz, Inc.")
		XCTAssertEqual(account["NumberOfEmployees"], 123)
		XCTAssertNotNil(account.date(forField: "LastModifiedDate"))
		XCTAssertNil(account["CEO"] as String?)
		XCTAssertEqual(account.value(forField: "TaxRate"), 0.050)
		XCTAssertEqual(account.url(forField: "Website"), URL(string: "https://tiny.biz")!)
		XCTAssertFalse(account.bool(forField: "BigCompany?")!)
	}
}
