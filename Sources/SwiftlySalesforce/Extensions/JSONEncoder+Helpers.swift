import Foundation

// Borrowed from https://stackoverflow.com/questions/63077827/how-can-i-encode-a-codable-type-by-specifying-a-subset-of-its-codingkeys/63080358
public extension JSONEncoder {
    
    func withEncodeSubset<CodingKeys>(keysToEncode: [CodingKeys]) -> JSONEncoder {
        userInfo[.keysToEncode] = keysToEncode
        return self
    }
    
    func withDateEncodingStrategy(_ strategy: DateEncodingStrategy) -> JSONEncoder {
        self.dateEncodingStrategy = strategy
        return self
    }
}
