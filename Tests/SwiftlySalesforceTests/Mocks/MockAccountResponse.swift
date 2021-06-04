/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

struct MockAccountResponse {
    
    var id: String = "0011Y00003HVMu4QAH"
    
    var json: String { """
    {
      "attributes" : {
        "type" : "Account",
        "url" : "/services/data/v51.0/sobjects/Account/\(id)"
      },
      "Id" : "\(id)",
      "IsDeleted" : false,
      "MasterRecordId" : null,
      "Name" : "Alaska Center for Performing Arts",
      "Type" : "Customer - Channel",
      "RecordTypeId" : null,
      "ParentId" : null,
      "BillingStreet" : "621 West 6th Avenue",
      "BillingCity" : "Anchorage",
      "BillingState" : "AK",
      "BillingPostalCode" : "99501",
      "BillingCountry" : "US",
      "BillingLatitude" : 61.217061,
      "BillingLongitude" : -149.894342,
      "BillingGeocodeAccuracy" : "Address",
      "BillingAddress" : {
        "city" : "Anchorage",
        "country" : "US",
        "geocodeAccuracy" : "Address",
        "latitude" : 61.217061,
        "longitude" : -149.894342,
        "postalCode" : "99501",
        "state" : "AK",
        "street" : "621 West 6th Avenue"
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
      "Phone" : "9075551212",
      "Fax" : null,
      "AccountNumber" : "445",
      "Website" : "www.coolcorp1.net",
      "PhotoUrl" : "/services/images/photo/0011Y00003HVMu4QAH",
      "Sic" : null,
      "Industry" : null,
      "AnnualRevenue" : null,
      "NumberOfEmployees" : null,
      "Ownership" : null,
      "TickerSymbol" : null,
      "Description" : "A very large customer.",
      "Rating" : null,
      "Site" : null,
      "OwnerId" : "005i00000016PdaAAE",
      "CreatedDate" : "2021-04-08T18:39:16.000+0000",
      "CreatedById" : "005i00000016PdaAAE",
      "LastModifiedDate" : "2021-04-27T19:33:04.000+0000",
      "LastModifiedById" : "005i00000016PdaAAE",
      "SystemModstamp" : "2021-04-27T19:33:04.000+0000",
      "LastActivityDate" : null,
      "LastViewedDate" : "2021-04-27T19:33:05.000+0000",
      "LastReferencedDate" : "2021-04-27T19:33:05.000+0000",
      "Jigsaw" : null,
      "JigsawCompanyId" : null,
      "AccountSource" : null,
      "SicDesc" : null,
      "playgroundorg__CustomerPriority__c" : null,
      "playgroundorg__SLA__c" : null,
      "playgroundorg__Active__c" : null,
      "playgroundorg__NumberofLocations__c" : null,
      "playgroundorg__UpsellOpportunity__c" : null,
      "playgroundorg__SLASerialNumber__c" : null,
      "playgroundorg__SLAExpirationDate__c" : null,
      "playgroundorg__Owners_Manager_Name__c" : "User, Test",
      "mikesnamespace1__Active__c" : null,
      "mikesnamespace1__CustomerPriority__c" : null,
      "mikesnamespace1__NumberofLocations__c" : null,
      "mikesnamespace1__SLAExpirationDate__c" : null,
      "mikesnamespace1__SLASerialNumber__c" : null,
      "mikesnamespace1__SLA__c" : null,
      "mikesnamespace1__UpsellOpportunity__c" : null,
      "playgroundorg__Custom_Date_Field__c" : "2021-04-08",
      "playgroundorg__Controlling_Picklist__c" : "USA",
      "playgroundorg__Controlled_Picklist__c" : "Chicago",
      "namespace2__Is_Covered__c" : true
    }
    """
    }
}

