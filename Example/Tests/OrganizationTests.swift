//
//  OrganizationTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class OrganizationTests: XCTestCase {
	
	let json = """
	{
		"attributes" : {
			"type" : "Organization",
			"url" : "/services/data/v41.0/sobjects/Organization/00Di0000000bcK3EAI"
		},
		"Id" : "00Di0000000bcK3EAI",
		"Name" : "Mega Corp., Inc.",
		"Division" : null,
		"Street" : "100 Main Street\\r\\nSuite A",
		"City" : "New York",
		"State" : "NY",
		"PostalCode" : "10024",
		"Country" : "US",
		"Latitude" : 40.1234,
		"Longitude" : null,
		"GeocodeAccuracy" : null,
		"Address" : {
			"city" : "New York",
			"country" : "US",
			"geocodeAccuracy" : null,
			"latitude" : 40.1234,
			"longitude" : null,
			"postalCode" : "10024",
			"state" : "NY",
			"street" : "100 Main Street\\r\\nSuite A"
		},
		"Phone" : "(212) 555-1212",
		"Fax" : null,
		"PrimaryContact" : "Jane Jackson",
		"DefaultLocaleSidKey" : "en_US",
		"LanguageLocaleKey" : "en_US",
		"ReceivesInfoEmails" : false,
		"ReceivesAdminInfoEmails" : false,
		"PreferencesRequireOpportunityProducts" : false,
		"PreferencesTransactionSecurityPolicy" : false,
		"PreferencesTerminateOldestSession" : false,
		"PreferencesLightningLoginEnabled" : true,
		"PreferencesOnlyLLPermUserAllowed" : false,
		"FiscalYearStartMonth" : 1,
		"UsesStartDateAsFiscalYearName" : false,
		"DefaultAccountAccess" : "Edit",
		"DefaultContactAccess" : "ControlledByParent",
		"DefaultOpportunityAccess" : "Edit",
		"DefaultLeadAccess" : "ReadEditTransfer",
		"DefaultCaseAccess" : "ReadEditTransfer",
		"DefaultCalendarAccess" : "HideDetailsInsert",
		"DefaultPricebookAccess" : "ReadSelect",
		"DefaultCampaignAccess" : "All",
		"SystemModstamp" : "2017-11-04T02:23:03.000+0000",
		"ComplianceBccEmail" : "jane.jackson.1234@yahoo.com",
		"UiSkin" : "Theme3",
		"SignupCountryIsoCode" : "US",
		"TrialExpirationDate" : null,
		"NumKnowledgeService" : 2,
		"OrganizationType" : "Developer Edition",
		"NamespacePrefix" : "playgroundorg",
		"InstanceName" : "NA88",
		"IsSandbox" : false,
		"WebToCaseDefaultOrigin" : "Web",
		"MonthlyPageViewsUsed" : 1206,
		"MonthlyPageViewsEntitlement" : 100000,
		"IsReadOnly" : false,
		"CreatedDate" : "2013-07-15T18:59:22.000+0000",
		"CreatedById" : "005i00000016PdaAAE",
		"LastModifiedDate" : "2017-11-04T02:23:03.000+0000",
		"LastModifiedById" : "005i00000016PdaAAE"
	}
	"""
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatItInitsWithJSON() {
		
		guard let data = json.data(using: .utf8), let org = try? JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(Organization.self, from: data) else {
			XCTFail()
			return
		}
		
		XCTAssertEqual("Mega Corp., Inc.", org.name)
		XCTAssertNil(org.division)
		XCTAssertEqual("New York", org.address?.city)
		XCTAssertEqual("NY", org.address?.state)
		XCTAssertEqual("10024", org.address?.postalCode)
		XCTAssertEqual("US", org.address?.country)
		XCTAssertEqual(40.1234, org.address?.latitude)
		XCTAssertEqual("(212) 555-1212", org.phone)
		XCTAssertEqual("Jane Jackson", org.primaryContact)
		XCTAssertEqual("jane.jackson.1234@yahoo.com", org.complianceBCCEmail)
		XCTAssertFalse(org.isSandbox)
		XCTAssertNil(org.trialExpirationDate)
		XCTAssertEqual("Developer Edition", org.type)
		XCTAssertEqual("playgroundorg", org.namespacePrefix)
		XCTAssertEqual("NA88", org.instanceName)
		XCTAssertEqual(1206, org.monthlyPageViewsUsed)
		XCTAssertEqual(100000, org.monthlyPageViewsEntitlement)
		XCTAssertEqual(DateFormatter.salesforceDateTimeFormatter.date(from: "2013-07-15T18:59:22.000+0000"), org.createdDate)
    }
}
