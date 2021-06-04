/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

internal extension Publisher {
    
    func tryCatchUserAuthenticationRequiredError<P>(_ handler: @escaping () -> P) -> Publishers.TryCatch<Self, P> where P : Publisher, Self.Output == P.Output {
        tryCatch { (error) throws -> P in
            guard let err = error as? SalesforceError, err == SalesforceError.userAuthenticationRequired else {
                throw error
            }
            return handler()
        }
    }
}
