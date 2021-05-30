/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

/**
Address data for a standard Salesforce object.
 
# Reference
[Address Compound Fields](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/compound_fields_address.htm)
*/
public struct Address: Decodable {
    
    public enum GeocodeAccuracy: String, Decodable {
        case address = "Address"
        case nearAddress = "NearAddress"
        case block = "Block"
        case street = "Street"
        case extendedZip = "ExtendedZip"
        case zip = "Zip"
        case city = "Neighborhood"
        case county = "County"
        case state = "State"
        case unknown = "Unknown"
    }
    
    public let city: String?
    public let country: String?
    public let countryCode: String?
    public let geocodeAccuracy: GeocodeAccuracy?
    public let latitude: Double?
    public let longitude: Double?
    public let postalCode: String?
    public let state: String?
    public let stateCode: String?
    public let street: String?
}
