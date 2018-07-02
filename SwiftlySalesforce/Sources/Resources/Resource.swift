//
//  Resource.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 7/2/18.
//

import Foundation

public protocol Resource {
	func request(with authorization: Authorization) throws -> URLRequest
}
