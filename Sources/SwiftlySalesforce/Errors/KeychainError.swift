import Foundation

enum KeychainError: Error, Equatable {
    case readFailure(status: OSStatus)
    case writeFailure(status: OSStatus)
    case deleteFailure(status: OSStatus)
    case itemNotFound
}
