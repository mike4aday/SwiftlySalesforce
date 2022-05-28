import Foundation

// Borrowed from https://stackoverflow.com/questions/63077827/how-can-i-encode-a-codable-type-by-specifying-a-subset-of-its-codingkeys/63080358
extension CodingUserInfoKey {
    
    static let keysToEncode = CodingUserInfoKey(rawValue: "keysToEncode")!
}
