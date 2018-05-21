//
//  URLComponents+Parameters.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/20/18.
//

import Foundation

extension URLComponents {
	
	init?(string: String, parameters: [String: Any]?) {
		self.init(string: string)
		self.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
	}
}
