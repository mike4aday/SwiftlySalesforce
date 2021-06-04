//
//  File.swift
//  
//
//  Created by Michael Epstein on 5/5/21.
//

import Foundation

public struct Identity: Codable {
    var userID: String
    var orgID: String
    var username: String
    var displayName: String
    var email: String
    var firstName: String
    var lastName: String
    var timezone: String
    var photos: Photos
    var street: String?
    var city: String?
    var country: String?
    var state: String?
    var zip: String?
    var mobilePhone: String?
    var isActive: Bool
    var userType: String
    var language: String
    var locale: String
    var utcOffset: Int
    var lastModifiedDate: Date
    
    public struct Photos: Codable {
        var picture: URL
        var thumbnail: URL
    }
}

extension Identity {
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case orgID = "organization_id"
        case username
        case displayName = "display_name"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case timezone
        case photos
        case street = "addr_street"
        case city = "addr_city"
        case state = "addr_state"
        case country = "addr_country"
        case zip = "addr_zip"
        case mobilePhone = "mobile_phone"
        case isActive = "active"
        case userType = "user_type"
        case language
        case locale
        case utcOffset
        case lastModifiedDate = "last_modified_date"
    }
}
