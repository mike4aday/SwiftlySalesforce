//
//  ObjectMetadataTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 7/8/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ObjectMetadataTests: XCTestCase, MockData {
    
	var decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateTimeFormatter)
	
	override func setUp() {
		super.setUp()
	}
	
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItInitsObjectMetadataForAccount() {
		
		let data = read(fileName: "MockAccountMetadata", ofType: "json")!
		let desc = try! decoder.decode(ObjectMetadata.self, from: data)
		let fields = Dictionary(items: desc.fields, key: { $0.name })
		let field = fields["Type"]!

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
		XCTAssertEqual(desc.label, "Account")
		XCTAssertEqual(desc.name, "Account")
		XCTAssertEqual(desc.pluralLabel, "Accounts")
		XCTAssertEqual(desc.pluralLabel, desc.labelPlural)
		XCTAssertTrue(desc.fields.count > 0)
		
		XCTAssertTrue(field.isCreateable)
		XCTAssertFalse(field.isCustom)
		XCTAssertNil(field.defaultValue)
		XCTAssertNil(field.helpText)
		XCTAssertEqual(field.helpText, field.inlineHelpText)
		XCTAssertFalse(field.isEncrypted)
		XCTAssertTrue(field.isSortable)
		XCTAssertEqual(field.label, "Account Type")
		XCTAssertEqual(field.length, 40)
		XCTAssertEqual(field.name, "Type")
		XCTAssertTrue(field.isNillable)
		XCTAssertTrue(field.relatedTypes.count == 0)
		XCTAssertNil(field.relationshipName)
		XCTAssertEqual(field.type, "picklist")
		XCTAssertTrue(field.isUpdateable)
		XCTAssertTrue(field.picklistValues.count > 0)
	}
	
	func testThatItInitsObjectMetadataForContact() {
		
		let data = read(fileName: "MockContactMetadata", ofType: "json")!
		let desc = try! decoder.decode(ObjectMetadata.self, from: data)
		let fields = Dictionary(items: desc.fields, key: { $0.name })
		let field = fields["ReportsToId"]!
		
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
		XCTAssertEqual(desc.label, "Contact")
		XCTAssertEqual(desc.name, "Contact")
		XCTAssertEqual(desc.pluralLabel, "Contacts")
		XCTAssertEqual(desc.pluralLabel, desc.labelPlural)
		XCTAssertTrue(desc.fields.count > 0)
		
		XCTAssertTrue(field.isCreateable)
		XCTAssertFalse(field.isCustom)
		XCTAssertNil(field.defaultValue)
		XCTAssertNil(field.helpText)
		XCTAssertEqual(field.helpText, field.inlineHelpText)
		XCTAssertFalse(field.isEncrypted)
		XCTAssertTrue(field.isSortable)
		XCTAssertEqual(field.label, "Reports To ID")
		XCTAssertEqual(field.length, 18)
		XCTAssertEqual(field.name, "ReportsToId")
		XCTAssertTrue(field.isNillable)
		XCTAssertTrue(field.relatedTypes == ["Contact"])
		XCTAssertEqual(field.relationshipName, "ReportsTo")
		XCTAssertEqual(field.type, "reference")
		XCTAssertTrue(field.isUpdateable)
		XCTAssertTrue(field.picklistValues.count == 0)
	}
}
