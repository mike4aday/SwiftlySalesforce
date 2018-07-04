//
//  URLRequestConvertible.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public protocol URLRequestConvertible {
	func asURLRequest(with authorization: Authorization) throws -> URLRequest
}
