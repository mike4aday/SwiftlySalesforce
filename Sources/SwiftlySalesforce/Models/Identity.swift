import Foundation

public struct Identity {
    
    public var identityURL: URL
    public var userID: String
    public var orgID: String
    public var username: String
    public var displayName: String
    public var email: String
    public var firstName: String
    public var lastName: String
    public var timezone: String
    public var photos: Photos
    public var street: String?
    public var city: String?
    public var country: String?
    public var state: String?
    public var zip: String?
    public var mobilePhone: String?
    public var isActive: Bool
    public var userType: String
    public var language: String
    public var locale: String
    public var utcOffset: Int
    public var lastModifiedDate: Date
    
    public struct Photos: Codable {
        public var picture: URL
        public var thumbnail: URL
    }
}

extension Identity {
    
    var userIdentifier: UserIdentifier {
        return UserIdentifier(identityURL: self.identityURL)
    }
}

extension Identity: Codable {
    
    enum CodingKeys: String, CodingKey {
        case identityURL = "id"
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
