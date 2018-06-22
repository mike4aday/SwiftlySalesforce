//
//  Resource.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//
import Foundation

protocol Resource {
	func request(with authorization: Authorization) throws -> URLRequest
}
