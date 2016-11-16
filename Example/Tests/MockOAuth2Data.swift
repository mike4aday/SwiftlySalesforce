//
//  MockOAuth2Data.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import XCTest
import SwiftlySalesforce

protocol MockOAuth2Data: class {
	var refreshToken: String? { get }
}

extension MockOAuth2Data {
	
	var data: NSDictionary? {
		guard let path = Bundle(for: type(of: self)).path(forResource: "OAuth2", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) else {
			return nil
		}
		return dict
	}
	
	var accessToken: String? {
		return data?["AccessToken"] as? String 
	}
	
	var refreshToken: String? {
		return data?["RefreshToken"] as? String 
	}
	
	var instanceURL: URL? {
		return URL(string: data?["InstanceURL"] as? String)
	}
	
	var identityURL: URL? {
		return URL(string: data?["IdentityURL"] as? String)
	}
	
	var consumerKey: String? {
		return data?["ConsumerKey"] as? String
	}
	
	var redirectURL: URL? {
		return URL(string: data?["RedirectURL"] as? String)
	}
}

