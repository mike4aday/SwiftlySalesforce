//
//  JSONDecoder+DateFormatter.swift
//  Pods-SwiftlySalesforce_Example
//
//  Created by Michael Epstein on 6/13/18.
//

import Foundation

public extension JSONDecoder {
	
	convenience init(dateFormatter: DateFormatter) {
		self.init()
		self.dateDecodingStrategy = .formatted(dateFormatter)
	}
}
