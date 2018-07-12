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

/// Alias for PromiseKit's `firstly` function
/// - Note: the block you pass excecutes immediately on the current thread/queue.
public func first<U: Thenable>(execute body: () throws -> U) -> Promise<U.T> {
	return PromiseKit.firstly(execute: body)
}

/// - See: first()
public func first<T>(execute body: () -> Guarantee<T>) -> Guarantee<T> {
	return PromiseKit.firstly(execute: body)
}
