//
//  RecordTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class RecordTests: XCTestCase, MockData {
	
	let decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateFormatter)
	let encoder = JSONEncoder()

    override func setUp() {
        super.setUp()
		encoder.dateEncodingStrategy = .iso8601
		encoder.outputFormatting = .prettyPrinted
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatItInitsFromCoder() throws {
		
		let data = read(fileName: "MockAccount", ofType: "json")!
		let account = try! decoder.decode(Record.self, from: data)

		XCTAssertEqual(account.id, "0011Y00002LZRxeQAH")
		XCTAssertEqual(account.id, account.string(forField: "Id"))
		XCTAssertEqual(account.type, "Account")
		XCTAssertEqual(account.url(forField: "Website")?.absoluteString, "https://www.megacorp.com")
		XCTAssertEqual(account.int(forField: "NumberOfEmployees"), 12345)
		XCTAssertEqual(account.double(forField: "AnnualRevenue"), 543210.00)
		XCTAssertEqual(account.float(forField: "AnnualRevenue"), 543210.0)
		XCTAssertNotNil(account.date(forField: "CreatedDate"))
		XCTAssertEqual(account.value(forField: "BillingCountry"), "US")
		XCTAssertNotNil(account.value(forField: "LastModifiedDate") as Date?)
		XCTAssertNil(account.value(forField: "LastReferencedDate") as Date?)
		XCTAssertEqual(account["Name"], "Megacorp, Inc.")
		XCTAssertEqual(account["Website"], URL(string: "https://www.megacorp.com")!)
		XCTAssertNotNil(account["PhotoUrl"] as String?)
		XCTAssertNil(account["Phone"] as String?)
    }
	
	func testThatItMutatesAndEncodes() {
		
		let data = read(fileName: "MockAccount", ofType: "json")!
		var account = try! decoder.decode(Record.self, from: data)
		
		account.setValue("Huge Corporation, Inc.", forField: "Name")
		account.setValue("Conglomerate", forField: "Type")
		account.setValue(nil, forField: "BillingPostalCode")
		account.setValue(Date(), forField: "LastViewedDate")
		account.setValue(1234.56, forField: "ShippingFees")
		account.setValue(1, forField: "NumberOfEmployees")
		account.setValue(URL(string: "https://www.corp.com")!, forField: "Website")
		account.setValue(false, forField: "Flag")
		account.setValue(Float(123456789.789), forField: "Rate")
		let json = try! encoder.encode(account)
		let rehydratedAccount = try! decoder.decode(Record.self, from: json)
		
		XCTAssertEqual(account["Name"], "Huge Corporation, Inc.")
		XCTAssertEqual(account["Type"], "Conglomerate")
		XCTAssertNil(account.string(forField: "BillingPostalCode"))
		XCTAssertNotNil(account.date(forField: "LastViewedDate"))
		XCTAssertEqual(account["ShippingFees"], 1234.56)
		
		XCTAssertNil(rehydratedAccount.id)
		XCTAssertNil(rehydratedAccount.string(forField: "Id"))
		XCTAssertEqual(rehydratedAccount["Name"] as String?, account["Name"] as String?)
		XCTAssertEqual(rehydratedAccount["ShippingFees"], 1234.56)
		XCTAssertEqual(rehydratedAccount.int(forField: "NumberOfEmployees"), 1)
		XCTAssertEqual(rehydratedAccount["Website"], account.value(forField: "Website") as URL?)
		XCTAssertFalse(rehydratedAccount.bool(forField: "Flag")!)
		XCTAssertEqual(rehydratedAccount.float(forField: "Rate"), 123456789.789)
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
		let account = Record(type: "Account", fields: dict)
		
		XCTAssertEqual(account["Name"], "Tiny Biz, Inc.")
		XCTAssertEqual(account["NumberOfEmployees"], 123)
		XCTAssertNotNil(account.date(forField: "LastModifiedDate"))
		XCTAssertNil(account["CEO"] as String?)
		XCTAssertEqual(account.value(forField: "TaxRate"), 0.050)
		XCTAssertEqual(account.url(forField: "Website"), URL(string: "https://tiny.biz")!)
		XCTAssertFalse(account.bool(forField: "BigCompany?")!)
	}
}
