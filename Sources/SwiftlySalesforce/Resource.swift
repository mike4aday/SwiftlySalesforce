import Foundation

public enum Resource {
    
    static let defaultVersion = "57.0" // Spring '23
    
    static func path(for leaf: String, version: String = defaultVersion) -> String {
        "/services/data/v\(version)/\(leaf)"
    }
}
