import Foundation

public struct Credential: Codable, Equatable {
    
    public let accessToken: String
    public let instanceURL: URL
    public let identityURL: URL
    public let timestamp: Date
    public let refreshToken: String?
    public let siteURL: URL?
    public let siteID: String?
    
    internal init(
        accessToken: String,
        instanceURL: URL,
        identityURL: URL,
        timestamp: Date,
        refreshToken: String? = nil,
        siteURL: URL? = nil,
        siteID: String? = nil
    ) {
        self.accessToken = accessToken
        self.instanceURL = instanceURL
        self.identityURL = identityURL
        self.timestamp = timestamp
        self.refreshToken = refreshToken
        self.siteURL = siteURL
        self.siteID = siteID
    }
    
    /// The ID of the Salesforce User record associated with this credential.
    var userID: String {
        return identityURL.lastPathComponent
    }
    
    /// The ID of the Salesforce Organization record associated with this credential.
    var orgID: String {
        return identityURL.deletingLastPathComponent().lastPathComponent
    }
}

internal extension Credential {
    
    init?(fromPercentEncoded: String, andRefreshToken: String? = nil) {
        
        var comps = URLComponents()
        comps.percentEncodedQuery = fromPercentEncoded
        
        // Non-nillable properties
        guard let queryItems: [URLQueryItem] = comps.queryItems,
              let accessToken: String = queryItems["access_token"],
              let instanceURL: URL = queryItems["instance_url"].flatMap({ URL(string: $0) }),
              let identityURL: URL = queryItems["id"].flatMap({ URL(string: $0) }),
              let timestamp: Date = queryItems["issued_at"].flatMap({ Double($0) }).map({ Date(timeIntervalSince1970: $0/1000) }) else {
                return nil
            }

        // Nillable properties
        let refreshToken: String? = queryItems["refresh_token"] ?? andRefreshToken
        let siteURL: URL? = queryItems["sfdc_site_url"].flatMap({ URL(string: $0) })
        let siteID: String? = queryItems["sfdc_site_id"]
        
        self.init(
            accessToken: accessToken,
            instanceURL: instanceURL,
            identityURL: identityURL,
            timestamp: timestamp,
            refreshToken: refreshToken,
            siteURL: siteURL,
            siteID: siteID
        )
    }
}

