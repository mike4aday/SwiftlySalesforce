//
//  TaskForceError.swift
//  Example for SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.

public enum TaskForceError: Error {
	case generic(code: Int, message: String)
}
