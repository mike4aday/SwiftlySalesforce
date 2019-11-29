//
//  Dictionary+URL.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

public extension Dictionary where Key == String, Value == String {
    
    func asURLQueryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    func asPercentEncodedString() -> String? {
        var comps = URLComponents()
        comps.queryItems = self.asURLQueryItems()
        return comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    }
}
