//
//  Resource.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation

enum Resource {
	
	case query(soql: String, version: String)
	case queryNext(path: String)
	case retrieve(type: String, id: String, fields: [String]?, version: String)
}
