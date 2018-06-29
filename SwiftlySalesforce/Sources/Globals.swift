//
//  Globals.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import PromiseKit

public typealias Promise = PromiseKit.Promise
public typealias DataResponse = (data: Data, response: URLResponse)
public typealias Validator = (DataResponse) throws -> DataResponse

/// An "alias" for PromiseKit's "firstly" function
/// See "firstly" at https://github.com/mxcl/PromiseKit/blob/master/Documentation/GettingStarted.md#firstly
public func first<U: Thenable>(execute body: () throws -> U) -> Promise<U.T> {
	return PromiseKit.firstly(execute: body)
}
