/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Combine

public extension AnyPublisher {
    
    // Borrowed from https://www.swiftbysundell.com/articles/extending-combine-with-convenience-apis/
    static func just(_ output: Output) -> Self {
        Just(output)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    static func just(_ output: @autoclosure () throws -> Output) -> Self where Failure == Error {
        Just(())
            .tryMap { try output() }
            .eraseToAnyPublisher()
    }
        
    // Borrowed from https://www.swiftbysundell.com/articles/extending-combine-with-convenience-apis/
    static func fail(with error: Failure) -> Self {
        Fail(error: error).eraseToAnyPublisher()
    }
}
