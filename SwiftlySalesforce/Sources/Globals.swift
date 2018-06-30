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
