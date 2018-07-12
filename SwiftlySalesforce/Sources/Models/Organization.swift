//
//  Organization.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

/// Represents key configuration information for a Salesforce organization ("org").
/// See: https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_organization.htm

public struct Organization: Decodable {
	
	var id: String
	var name: String
	var division: String?
	var address: Address?
	var phone: String?
	var fax: String?
	var primaryContact: String?
	var languageLocaleKey: String?
	var complianceBCCEmail: String?
	var trialExpirationDate: Date?
	var type: String
	var namespacePrefix: String?
	var instanceName: String
	var isSandbox: Bool
	var monthlyPageViewsUsed: Int
	var monthlyPageViewsEntitlement: Int
	var createdDate: Date
	
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case name = "Name"
		case division = "Division"
		case address = "Address"
		case phone = "Phone"
		case fax = "Fax"
		case primaryContact = "PrimaryContact"
		case languageLocaleKey = "LanguageLocaleKey"
		case complianceBCCEmail = "ComplianceBccEmail"
		case trialExpirationDate = "TrialExpirationDate"
		case type = "OrganizationType"
		case namespacePrefix = "NamespacePrefix"
		case instanceName = "InstanceName"
		case isSandbox = "IsSandbox"
		case monthlyPageViewsUsed = "MonthlyPageViewsUsed"
		case monthlyPageViewsEntitlement = "MonthlyPageViewsEntitlement"
		case createdDate = "CreatedDate"
	}
}
