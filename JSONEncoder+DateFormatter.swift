//
//  JSONEncoder+DateFormatter.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import Foundation

public extension JSONEncoder {
	
	public convenience init(dateFormatter: DateFormatter) {
		self.init()
		self.dateEncodingStrategy = .formatted(dateFormatter)
	}
}
