//
//  Salesforce+DescribeLayout.swift
//  SFDC Tool
//
//  Created by Alexey Malashin on 28.05.2020.
//  Copyright © 2020 Alexey Malashin. All rights reserved.
//

import Foundation
import SwiftlySalesforce

extension Salesforce {
    // according to: http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/
    /// Get dependant list items by index from the parent list and validFor field
    func getDependantListItems(forList list: [ObjectPicklistValue], forIndex index: Int) -> [String] {
        return list
            .filter{
                let idx = index >> 3
                if let data = Data(base64Encoded: $0.validFor!), data.count > idx {
                    return Int(data[idx]) & (128 >> (index % 8)) > 0
                } else {
                    return false
                }
            }
            .map{ $0.value }
    }
}