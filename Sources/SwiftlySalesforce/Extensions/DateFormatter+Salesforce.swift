import Foundation

public extension DateFormatter {
        
    enum Length: String {
        case short = "yyyy-MM-dd"
        case long = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
    }
    
    static func salesforce(_ length: Length = .long) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = length.rawValue
        return formatter
    }
}
