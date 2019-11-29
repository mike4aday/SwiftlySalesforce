//
//  Org.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

public typealias Organization = Org

/// Holds information about a Salesforce org
public struct Org: Decodable {
    
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
