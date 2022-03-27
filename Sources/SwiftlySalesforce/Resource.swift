import Foundation

public enum Resource {
    
    static let defaultVersion = "54.0" // Spring '22
    
    static func path(for leaf: String, version: String = defaultVersion) -> String {
        "/services/data/v\(version)/\(leaf)"
    }
}
