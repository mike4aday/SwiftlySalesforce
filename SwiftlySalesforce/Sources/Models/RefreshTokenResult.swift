//
//  RefreshTokenResult.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 10/9/18.
//

import Foundation

internal struct RefreshTokenResult {
	let accessToken: String
	let instanceURL: URL
	let identityURL: URL
	let issuedAt: UInt?
	let communityURL: URL?
	let communityID: String?
}

extension RefreshTokenResult: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case instanceURL = "instance_url"
		case identityURL = "id"
		case issuedAt = "issued_at"
		case communityURL = "sfdc_community_url"
		case communityID = "sfdc_community_id"
	}
}
