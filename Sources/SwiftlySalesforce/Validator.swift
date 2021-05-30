/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation

public struct Validator {
    
    public var validate: (URLSession.DataTaskPublisher.Output) throws -> ()
    
    public static let `default` = Validator { output in
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        switch httpResponse.statusCode {
        case 200..<300:
            break //OK
        case 401:
            throw SalesforceError.userAuthenticationRequired
        default:
            if let errs = try? JSONDecoder.salesforce.decode([SalesforceError].self, from: output.data), errs.count > 0 {
                throw errs[0]
            }
            else if let err = try? JSONDecoder.salesforce.decode(SalesforceError.self, from: output.data) {
                throw err
            }
            else {
                throw SalesforceError.responseError(response: httpResponse)
            }
        }
    }
}
