/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

/// Holds the result of a successful OAuth2 authentication, including the Salesforce access token and the refresh token, if available.
/// # Reference
/// [OAuth 2.0 User-Agent Flow](https://help.salesforce.com/articleView?id=remoteaccess_oauth_user_agent_flow.htm)
public struct Credential: Codable, Equatable {
    public let accessToken: String
    public let instanceURL: URL
    public let identityURL: URL
    public let refreshToken: String?
    public let siteURL: URL?
    public let siteID: String?
    public let timestamp: Date?
}

public extension Credential {
    
    /// The identifier for the user associated with this credential.
    ///
    /// Swiftly Salesforce uses the identity URL as a unique identifier for securely storing and retrieving credentials.
    /// # Reference
    /// [Identity URLs](https://help.salesforce.com/articleView?id=sf.remoteaccess_using_openid.htm&type=5)
    var user: UserIdentifier {
        return identityURL
    }
    
    /// The ID of the Salesforce User record associated with this credential.
    var userID: String {
        return user.lastPathComponent
    }
    
    /// The ID of the Salesforce Organization record associated with this credential.
    var orgID: String {
        return user.deletingLastPathComponent().lastPathComponent
    }
}

internal extension Credential {
    
    init?(fromURLEncodedString string: String, andRefreshToken refreshToken: String? = nil) {
        guard let queryItems = URLComponents(percentEncodedQuery: string).queryItems,
              let accessToken = queryItems["access_token"],
              let instanceURL = URL(string: queryItems["instance_url"]),
              let identityURL = URL(string: queryItems["id"]) else {
            return nil
        }
        
        // Set properties, including optional values
        self.accessToken = accessToken
        self.instanceURL = instanceURL
        self.identityURL = identityURL
        self.refreshToken = queryItems["refresh_token"] ?? refreshToken
        self.siteURL = URL(string: queryItems["sfdc_site_url"])
        self.siteID = queryItems["sfdc_site_id"]
        self.timestamp = {
            guard let str = queryItems["issued_at"], let millisecs = Double(str) else {
                return nil
            }
            return Date(timeIntervalSince1970: millisecs/1000)
        }()
    }
    
    init(accessToken: String, instanceURL: URL, identityURL: URL) {
        self.init(accessToken: accessToken, instanceURL: instanceURL, identityURL: identityURL, refreshToken: nil, siteURL: nil, siteID: nil, timestamp: nil)
    }
}
