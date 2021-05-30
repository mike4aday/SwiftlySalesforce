/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

public extension Publisher {
    
    // Borrowed from https://www.swiftbysundell.com/articles/extending-combine-with-convenience-apis/
    func unwrap<T>(orThrow error: @escaping @autoclosure () -> Failure) -> Publishers.TryMap<Self, T> where Output == Optional<T> {
        tryMap { output in
            switch output {
            case .some(let value):
                return value
            case nil:
                throw error()
            }
        }
    }
        
    // Borrowed from https://www.swiftbysundell.com/articles/extending-combine-with-convenience-apis/
    func validate(using validator: @escaping (Output) throws -> Void) -> Publishers.TryMap<Self, Output> {
        tryMap { output in
            try validator(output)
            return output
        }
    }
    
    func onCompletion(doThis: @escaping (Subscribers.Completion<Self.Failure>) -> ()) ->  Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: doThis)
    }
}
