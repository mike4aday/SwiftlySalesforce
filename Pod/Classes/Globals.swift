//
//  Globals.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2016. All rights reserved.
//

import PromiseKit

public typealias Promise = PromiseKit.Promise
public typealias Record = [String: Any]

/// An "alias" for PromiseKit's "firstly" function
/// See "firstly" at https://github.com/mxcl/PromiseKit/blob/master/Documentation/GettingStarted.md
public func first<T>(execute body: () throws -> Promise<T>) -> Promise<T> {
	return PromiseKit.firstly(execute: body)
}

/// "Aliases" for PromiseKit's "when(fulfilled:)" functions
/// See "when" at https://github.com/mxcl/PromiseKit/blob/master/Documentation/GettingStarted.md
public func fulfill<U, V>(_ firstPromise: Promise<U>, _ secondPromise: Promise<V>) -> Promise<(U, V)> {
	return PromiseKit.when(fulfilled: firstPromise, secondPromise)
}
public func fulfill<U, V, W>(_ firstPromise: Promise<U>, _ secondPromise: Promise<V>, _ thirdPromise: Promise<W>) -> Promise<(U, V, W)> {
	return PromiseKit.when(fulfilled: firstPromise, secondPromise, thirdPromise)
}
public func fulfill<U, V, W, X>(_ firstPromise: Promise<U>, _ secondPromise: Promise<V>, _ thirdPromise: Promise<W>, _ fourthPromise: Promise<X>) -> Promise<(U, V, W, X)> {
	return PromiseKit.when(fulfilled: firstPromise, secondPromise, thirdPromise, fourthPromise)
}
