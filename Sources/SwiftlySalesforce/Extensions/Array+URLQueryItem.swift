import Foundation

public extension Array where Element == URLQueryItem {
    
    // Borrowed from https://www.avanderlee.com/swift/url-components/
    init<T: LosslessStringConvertible>(_ dictionary: [String: T]) {
        self = dictionary.map({ (key, value) -> Element in
            URLQueryItem(name: key, value: String(value))
        })
    }
}
