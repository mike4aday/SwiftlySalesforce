import Foundation

public extension Collection where Element == URLQueryItem {
    
    // Borrowed from https://www.avanderlee.com/swift/url-components/
    subscript(_ name: String) -> String? {
        first(where: { $0.name == name })?.value
    }
}
