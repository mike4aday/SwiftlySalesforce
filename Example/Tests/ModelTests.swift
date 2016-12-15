//
//  ModelTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class ModelTests: XCTestCase, MockJSONData {
	
    override func setUp() {
        super.setUp()
	}
    
    override func tearDown() {
        super.tearDown()
    }
    
	func testThatItInitsUserInfo() {
		
		// Given
		guard let json = identityJSON else {
			XCTFail()
			return
		}
		
		// When
		let userInfo = UserInfo(json: json)
		
		// Then
		XCTAssertEqual(userInfo.displayName!, "Alan Van")
		XCTAssertNil(userInfo.mobilePhone)
		XCTAssertNil(userInfo.username)
		XCTAssertEqual(userInfo.userID!, "005x0000001S2b9")
		XCTAssertEqual(userInfo.orgID!, "00Dx0000001T0zk")
		XCTAssertEqual(userInfo.userType!, "STANDARD")
		XCTAssertEqual(userInfo.language!, "en_US")
		XCTAssertEqual(userInfo.lastModifiedDate!, DateFormatter.salesforceDateTimeFormatter.date(from: "2010-06-28T20:54:09.000+0000"))
		XCTAssertEqual(userInfo.locale!, "en_US")
		XCTAssertEqual(userInfo.thumbnailURL!, URL(string: "https://yourInstance.salesforce.com/profilephoto/005/T"))
	}
	
	func testThatItInitsQueryResult() {
		
		// Given
		guard let json = queryResultJSON else {
			XCTFail()
			return
		}
		
		// When
		guard let queryResult = try? QueryResult(json: json) else {
			XCTFail()
			return
		}
		
		// Then
		XCTAssertEqual(queryResult.totalSize, 2)
		XCTAssertTrue(queryResult.isDone)
		XCTAssertEqual(queryResult.totalSize, 2)
		XCTAssertEqual(queryResult.records.count, queryResult.totalSize)
	}
	
	func testThatItInitsAccountDescription() {
		
		// Given
		guard let json = describeAccountResultJSON else {
			XCTFail()
			return
		}
		
		// When
		let desc = ObjectDescription(json: json)
		
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
		XCTAssertTrue(desc.fields.count > 0)
		if let field = desc.fields["Type"] {
			
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
			XCTAssertEqual(field.relatedTypes, field.referenceTo)
			XCTAssertNil(field.relationshipName)
			XCTAssertEqual(field.type, "picklist")
			XCTAssertTrue(field.isUpdateable)
			
			// Picklist values
			XCTAssertTrue(field.picklistValues.count == 7)
			XCTAssertTrue(field.picklistValues[0].value == "Prospect")
			XCTAssertTrue(field.picklistValues[0].isActive)
		}
		else {
			XCTFail()
		}
		if let field = desc.fields["ShippingLongitude"] {
			XCTAssertEqual(123456789, field.defaultValue as? Int)
		}
		else {
			XCTFail()
		}
	}
	
	func testThatItInitsTaskDescription() {
		
		// Given
		guard let json = describeTaskResultJSON else {
			XCTFail()
			return
		}
		
		// When
		let desc = ObjectDescription(json: json)
		
		// Then
		XCTAssertTrue(desc.isCreateable)
		XCTAssertFalse(desc.isCustom)
		XCTAssertFalse(desc.isCustomSetting)
		XCTAssertTrue(desc.isDeletable)
		XCTAssertFalse(desc.isFeedEnabled)
		XCTAssertTrue(desc.isQueryable)
		XCTAssertTrue(desc.isSearchable)
		XCTAssertTrue(desc.isTriggerable)
		XCTAssertTrue(desc.isUndeletable)
		XCTAssertTrue(desc.isUpdateable)
		XCTAssertEqual(desc.keyPrefix, "00T")
		XCTAssertEqual(desc.label, "Task")
		XCTAssertEqual(desc.name, "Task")
		XCTAssertEqual(desc.pluralLabel, "Tasks")
		XCTAssertEqual(desc.pluralLabel, desc.labelPlural)
		XCTAssertTrue(desc.fields.count > 0)
		if let field = desc.fields["WhoId"] {
			// Test 'WhoId' field
			XCTAssertTrue(field.isCreateable)
			XCTAssertFalse(field.isCustom)
			XCTAssertNil(field.defaultValue)
			XCTAssertEqual("The inline help text for WhoId", field.helpText)
			XCTAssertEqual(field.helpText, field.inlineHelpText)
			XCTAssertFalse(field.isEncrypted)
			XCTAssertTrue(field.isSortable)
			XCTAssertEqual(field.label, "Name ID")
			XCTAssertEqual(field.length, 18)
			XCTAssertEqual(field.name, "WhoId")
			XCTAssertTrue(field.isNillable)
			XCTAssertTrue(field.picklistValues.count == 0)
			XCTAssertTrue(field.relatedTypes.count == 2)
			XCTAssertTrue(field.relatedTypes.contains("Lead"))
			XCTAssertTrue(field.relatedTypes.contains("Contact"))
			XCTAssertEqual(field.relatedTypes, field.referenceTo)
			XCTAssertEqual("Who", field.relationshipName)
			XCTAssertEqual(field.type, "reference")
			XCTAssertTrue(field.isUpdateable)
		}
		else {
			XCTFail()
		}
	}
}
