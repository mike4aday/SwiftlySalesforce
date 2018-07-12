//
//  ObjectDescriptionTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ObjectDescriptionTests: XCTestCase {
    
	var decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateTimeFormatter)
	
	override func setUp() {
		super.setUp()
	}
	
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItInitsObjectMetadataForAccount() {
		
		let data = TestUtils.shared.read(fileName: "MockAccountMetadata", ofType: "json")!
		let desc = try! decoder.decode(ObjectDescription.self, from: data)
		var fields = [String: FieldDescription]()
		for (name, fieldMetadata) in zip(desc.fields!.map({ $0.name }), desc.fields!) {
			fields[name] = fieldMetadata
		}
		let accountTypeField = fields["Type"]!

		XCTAssertTrue(desc.isCreateable)
		XCTAssertFalse(desc.isCustom)
		XCTAssertFalse(desc.isCustomSetting)
		XCTAssertTrue(desc.isDeletable)
		XCTAssertTrue(desc.isFeedEnabled)
		XCTAssertTrue(desc.isQueryable)
		XCTAssertTrue(desc.isSearchable)
		XCTAssertTrue(desc.isTriggerable)
		XCTAssertTrue(desc.isUndeletable)
		XCTAssertTrue(desc.isUpdateable)
		XCTAssertEqual(desc.keyPrefix, "001")
		XCTAssertEqual(desc.keyPrefix, desc.idPrefix)
		XCTAssertEqual(desc.label, "Account")
		XCTAssertEqual(desc.name, "Account")
		XCTAssertEqual(desc.pluralLabel, "Accounts")
		XCTAssertEqual(desc.pluralLabel, desc.labelPlural)
		XCTAssertTrue(desc.fields!.count > 0)
		
		XCTAssertTrue(accountTypeField.isCreateable)
		XCTAssertFalse(accountTypeField.isCustom)
		XCTAssertNil(accountTypeField.defaultValue)
		XCTAssertNil(accountTypeField.helpText)
		XCTAssertEqual(accountTypeField.helpText, accountTypeField.inlineHelpText)
		XCTAssertFalse(accountTypeField.isEncrypted)
		XCTAssertTrue(accountTypeField.isSortable)
		XCTAssertEqual(accountTypeField.label, "Account Type")
		XCTAssertEqual(accountTypeField.length, 40)
		XCTAssertEqual(accountTypeField.name, "Type")
		XCTAssertTrue(accountTypeField.isNillable)
		XCTAssertTrue(accountTypeField.relatedTypes.count == 0)
		XCTAssertNil(accountTypeField.relationshipName)
		XCTAssertEqual(accountTypeField.type, "picklist")
		XCTAssertTrue(accountTypeField.isUpdateable)
		XCTAssertTrue(accountTypeField.picklistValues.count > 0)
	}
	
	func testThatItInitsObjectMetadataForContact() {
		
		let data = TestUtils.shared.read(fileName: "MockContactMetadata", ofType: "json")!
		let desc = try! decoder.decode(ObjectDescription.self, from: data)
		var fields = [String: FieldDescription]()
		for (name, fieldMetadata) in zip(desc.fields!.map({ $0.name }), desc.fields!) {
			fields[name] = fieldMetadata
		}
		let reportsToField = fields["ReportsToId"]!
		
		XCTAssertTrue(desc.isCreateable)
		XCTAssertFalse(desc.isCustom)
		XCTAssertFalse(desc.isCustomSetting)
		XCTAssertTrue(desc.isDeletable)
		XCTAssertTrue(desc.isFeedEnabled)
		XCTAssertTrue(desc.isQueryable)
		XCTAssertTrue(desc.isSearchable)
		XCTAssertTrue(desc.isTriggerable)
		XCTAssertTrue(desc.isUndeletable)
		XCTAssertTrue(desc.isUpdateable)
		XCTAssertEqual(desc.keyPrefix, "003")
		XCTAssertEqual(desc.keyPrefix, desc.idPrefix)
		XCTAssertEqual(desc.label, "Contact")
		XCTAssertEqual(desc.name, "Contact")
		XCTAssertEqual(desc.pluralLabel, "Contacts")
		XCTAssertEqual(desc.pluralLabel, desc.labelPlural)
		XCTAssertTrue(desc.fields!.count > 0)
		
		XCTAssertTrue(reportsToField.isCreateable)
		XCTAssertFalse(reportsToField.isCustom)
		XCTAssertNil(reportsToField.defaultValue)
		XCTAssertNil(reportsToField.helpText)
		XCTAssertEqual(reportsToField.helpText, reportsToField.inlineHelpText)
		XCTAssertFalse(reportsToField.isEncrypted)
		XCTAssertTrue(reportsToField.isSortable)
		XCTAssertEqual(reportsToField.label, "Reports To ID")
		XCTAssertEqual(reportsToField.length, 18)
		XCTAssertEqual(reportsToField.name, "ReportsToId")
		XCTAssertTrue(reportsToField.isNillable)
		XCTAssertTrue(reportsToField.relatedTypes == ["Contact"])
		XCTAssertEqual(reportsToField.relatedTypes, reportsToField.referenceTo)
		XCTAssertEqual(reportsToField.relationshipName, "ReportsTo")
		XCTAssertEqual(reportsToField.type, "reference")
		XCTAssertTrue(reportsToField.isUpdateable)
		XCTAssertTrue(reportsToField.picklistValues.count == 0)
	}
}
