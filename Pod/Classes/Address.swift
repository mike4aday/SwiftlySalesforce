//
//  Address.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

/// Holds standard objects' compound address field data. 
/// See https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/compound_fields_address.htm

public struct Address {
	
	enum GeocodeAccuracy: String {
		case address = "Address"
		case nearAddress = "NearAddress"
		case block = "Blcok"
		case street = "Street"
		case extendedZip = "ExtendedZip"
		case zip = "Zip"
		case city = "Neighborhood"
		case county = "County"
		case state = "State"
		case unknown = "Unknown"
	}
	
	let city: String?
	let country: String?
	let countryCode: String?
	let geocodeAccuracy: GeocodeAccuracy?
	let latitude: Double?
	let longitude: Double?
	let postalCode: String?
	let state: String?
	let stateCode: String?
	let street: String?
	
	public init(json: [String: Any]) {
		city = json["city"] as? String
		country = json["country"] as? String
		countryCode = json["countryCode"] as? String
		geocodeAccuracy = GeocodeAccuracy(rawValue: json["geocodeAccuracy"] as? String ?? "")
		latitude = json["latitude"] as? Double
		longitude = json["longitude"] as? Double
		postalCode = json["postalCode"] as? String
		state = json["state"] as? String
		stateCode = json["stateCode"] as? String
		street = json["street"] as? String
	}
}
