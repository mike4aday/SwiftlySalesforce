//
//  Resource.swift
//
//  Created by Michael Epstein on 6/16/18.
//

import Foundation

protocol Resource {
	func request(with authorization: Authorization) throws -> URLRequest
}
