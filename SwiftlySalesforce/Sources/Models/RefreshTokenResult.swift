//
//  RefreshTokenResult.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 10/9/18.
//

import Foundation

struct RefreshTokenResult {
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
	
	public init(from decoder: Decoder) throws {
		
		// Top level container
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// Set properties
		self.accessToken = try container.decode(String.self, forKey: .accessToken)
		self.instanceURL = try container.decode(URL.self, forKey: .instanceURL)
		self.identityURL = try container.decode(URL.self, forKey: .identityURL)
		self.issuedAt = try {
			guard let s = try container.decodeIfPresent(String.self, forKey: .issuedAt) else {
				return nil
			}
			return UInt(s)
		}()
		self.communityURL = try container.decodeIfPresent(URL.self, forKey: .communityURL)
		self.communityID = try container.decodeIfPresent(String.self, forKey: .communityID)
	}
}
