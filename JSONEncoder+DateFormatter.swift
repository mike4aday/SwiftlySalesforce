//
//  JSONEncoder+DateFormatter.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/21/18.
//

import Foundation

public extension JSONEncoder {
	
	convenience init(dateFormatter: DateFormatter) {
		self.init()
		self.dateEncodingStrategy = .formatted(dateFormatter)
	}
}
