//
//  URLRequest+URLRequestConvertible.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

extension URLRequest: URLRequestConvertible {
	
	public func asURLRequest(with authorization: Authorization) throws -> URLRequest {
		var req = self // Copy
		try req.apply(authorization)
		return req
	}
}
