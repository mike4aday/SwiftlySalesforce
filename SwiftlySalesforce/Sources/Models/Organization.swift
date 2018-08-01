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
	
	public let id: String
	public let name: String
	public let division: String?
	public let address: Address?
	public let phone: String?
	public let fax: String?
	public let primaryContact: String?
	public let languageLocaleKey: String?
	public let complianceBCCEmail: String?
	public let trialExpirationDate: Date?
	public let type: String
	public let namespacePrefix: String?
	public let instanceName: String
	public let isSandbox: Bool
	public let monthlyPageViewsUsed: Int
	public let monthlyPageViewsEntitlement: Int
	public let createdDate: Date
	
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
