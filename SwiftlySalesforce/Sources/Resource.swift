//
//  Resource.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/17/18.
//

import Foundation

protocol Resource {
	func request(with authorization: Authorization) throws -> URLRequest
}
