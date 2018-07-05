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

	let json = """
	{
		"attributes" : {
			"type" : "Account",
			"url" : "/services/data/v41.0/sobjects/Account/0011Y00002LZRxeQAH"
		},
		"Id" : "0011Y00002LZRxeQAH",
		"IsDeleted" : false,
		"MasterRecordId" : null,
		"Name" : "Megacorp, Inc.",
		"Type" : null,
		"RecordTypeId" : null,
		"ParentId" : null,
		"BillingStreet" : null,
		"BillingCity" : null,
		"BillingState" : null,
		"BillingPostalCode" : "55141",
		"BillingCountry" : "US",
		"BillingLatitude" : null,
		"BillingLongitude" : null,
		"BillingGeocodeAccuracy" : null,
		"BillingAddress" : {
			"city" : "Pleasant Prairie",
			"country" : "US",
			"geocodeAccuracy" : null,
			"latitude" : null,
			"longitude" : null,
			"postalCode" : "55141",
			"state" : "WI",
			"street" : null
		},
		"ShippingStreet" : null,
		"ShippingCity" : null,
		"ShippingState" : null,
		"ShippingPostalCode" : null,
		"ShippingCountry" : null,
		"ShippingLatitude" : null,
		"ShippingLongitude" : null,
		"ShippingGeocodeAccuracy" : null,
		"ShippingAddress" : null,
		"Phone" : null,
		"Fax" : null,
		"AccountNumber" : null,
		"Website" : "https://www.megacorp.com",
		"PhotoUrl" : "/services/images/photo/0011Y00002LZRxeQAH",
		"Sic" : null,
		"Industry" : null,
		"AnnualRevenue" : 543210.0,
		"NumberOfEmployees" : 12345,
		"Ownership" : null,
		"TickerSymbol" : null,
		"Description" : null,
		"Rating" : null,
		"Site" : null,
		"OwnerId" : "005i00000016PdaAAE",
		"CreatedDate" : "2017-10-11T13:11:58.000+0000",
		"CreatedById" : "005i00000016PdaAAE",
		"LastModifiedDate" : "2017-10-11T13:11:58.000+0000",
		"LastModifiedById" : "005i00000016PdaAAE",
		"SystemModstamp" : "2017-10-12T00:02:54.000+0000",
		"LastActivityDate" : null,
		"LastViewedDate" : null,
		"LastReferencedDate" : null,
		"Jigsaw" : null,
		"JigsawCompanyId" : null,
		"AccountSource" : null,
		"SicDesc" : null,
		"playground__CustomerPriority__c" : null,
		"playground__SLA__c" : null,
		"playground__Active__c" : null,
		"playground__NumberofLocations__c" : null,
		"playground__UpsellOpportunity__c" : null,
		"playground__SLASerialNumber__c" : null,
		"playground__SLAExpirationDate__c" : null,
		"playground__Owners_Manager_Name__c" : "User, Test",
	}
	"""
	
	let decoder = JSONDecoder(dateFormatter: .salesforceDateTimeFormatter)
	let encoder = JSONEncoder(dateFormatter: .salesforceDateTimeFormatter)
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
    
    func testThatItInitsFromCoder() {
		
		guard let data = json.data(using: .utf8), let account = try? decoder.decode(SObject.self, from: data) else {
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
		
		guard let data = json.data(using: .utf8), var account = try? decoder.decode(SObject.self, from: data) else {
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
