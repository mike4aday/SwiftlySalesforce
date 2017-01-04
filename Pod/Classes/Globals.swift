//
//  Globals.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit

public typealias Promise = PromiseKit.Promise

/// An "alias" for PromiseKit's "firstly" function
public func first<T>(execute body: () throws -> Promise<T>) -> Promise<T> {
	return PromiseKit.firstly(execute: body)
}

/// Singleton instance of Salesforce class
public let salesforce = Salesforce.shared
