//
//  TaskForceError.swift
//  Example for SwiftlySalesforce
//
//  Created by Michael Epstein on 10/21/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

public enum TaskForceError: Error {
	case generic(code: Int, message: String)
}
