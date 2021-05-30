/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

public extension ConnectedApp {
    
    /// Gets information about the current user
    /// - Parameters:
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher.
    func identity(session: URLSession = .shared, allowsLogin: Bool = true) -> AnyPublisher<Identity, Error> {
        let service = IdentityService()
        let validator = Validator { output in
            if let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                throw SalesforceError.userAuthenticationRequired
            }
            else {
                return try Validator.default.validate(output)
            }
        }
        let decoder = JSONDecoder(dateDecodingStrategy: .iso8601)
        return go(service: service, session: session, allowsLogin: allowsLogin, validator: validator, decoder: decoder)
    }
}
