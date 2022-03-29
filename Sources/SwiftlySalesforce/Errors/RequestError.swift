import Foundation

struct RequestError: Error, CustomDebugStringConvertible {
    
    let debugDescription: String
    
    init(_ debugDescription: String) {
        self.debugDescription = debugDescription
    }
}
