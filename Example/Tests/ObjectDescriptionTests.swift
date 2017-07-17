//
//  ObjectDescriptionTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 7/8/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ObjectDescriptionTests: XCTestCase, MockData {
    
	var json: [String: Any]!
	
	override func setUp() {
		super.setUp()
		json = readJSONDictionary(fileName: "MockObjectDescription")!
	}

	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testThatItInitsObjectDescriptionForAccount() {
		
		// Given
		
		// When
		let desc = try! ObjectDescription(json: json)
		
		// Then
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
		XCTAssertTrue(desc.fields!.count > 0)
		if let field = desc.fields?["Type"] {
			
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
			XCTAssertTrue(field.relatedTypes?.count == 0)
			XCTAssertNil(field.relationshipName)
			XCTAssertEqual(field.type, "picklist")
			XCTAssertTrue(field.isUpdateable)
			
			// Picklist values
			XCTAssertTrue((field.picklistValues?.count)! > 0)
		}
		else {
			XCTFail()
		}
	}
}
