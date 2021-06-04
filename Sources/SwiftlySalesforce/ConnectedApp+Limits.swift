/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

public extension ConnectedApp {
    
    func limits(session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<[String:Limit], Error> {
        go(service: LimitsService(), session: session, allowsLogin: allowsLogin)
    }
}
