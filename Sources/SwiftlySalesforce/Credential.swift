//
//  Credential.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

/// Holds the result of a successful OAuth2 authentication.
/// See [OAuth 2.0 User-Agent Flow](https://help.salesforce.com/articleView?id=remoteaccess_oauth_user_agent_flow.htm).
public struct Credential: Codable, Equatable {
    public let accessToken: String
    public let instanceURL: URL
    public let identityURL: URL
    public let refreshToken: String?
    public let issuedAt: UInt?
    public let idToken: String?
    public let communityURL: URL?
    public let communityID: String?
}

public extension Credential {
    
    var userID: String {
        return identityURL.lastPathComponent
    }
    
    var orgID: String {
        return identityURL.deletingLastPathComponent().lastPathComponent
    }
    
    var organizationID: String {
        return orgID 
    }
}

public extension Credential {
    
    init(with redirectURL: URL) throws {
        
        // Salesforce returns OAuth2 result in the redirect URL's fragment
        // so let's make it a query string instead so we can parse with URLComponents
        guard let url = URL(string: redirectURL.absoluteString.replacingOccurrences(of: "#", with: "?")),
            let accessToken = url.queryItems(named: "access_token")?.first?.value,
            let instanceURL = URL(string: url.queryItems(named: "instance_url")?.first?.value ?? ""),
            let identityURL = URL(string: url.queryItems(named: "id")?.first?.value ?? ""),
            let issuedAtString = url.queryItems(named: "issued_at")?.first?.value,
            let issuedAt = UInt(issuedAtString) else {
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: [NSURLErrorFailingURLStringErrorKey: redirectURL])
        }
        
        // Parse values which *may* be present in the redirect URL, depending on Connected App configuration
        let refreshToken: String? = url.queryItems(named: "refresh_token")?.first?.value
        let idToken: String? = url.queryItems(named: "id_token")?.first?.value
        let communityID: String? = url.queryItems(named: "sfdc_community_id")?.first?.value
        let communityURL: URL? = URL(string: url.queryItems(named: "sfdc_community_url")?.first?.value ?? "")
        
        self.init(accessToken: accessToken,
            instanceURL: instanceURL,
            identityURL: identityURL,
            refreshToken: refreshToken,
            issuedAt: issuedAt,
            idToken: idToken,
            communityURL: communityURL,
            communityID: communityID)
    }
}
