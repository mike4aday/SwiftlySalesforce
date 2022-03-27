import Foundation

extension Error {
    
    var isAuthenticationRequired: Bool {
        return (self as? URLError).map { $0.code == URLError.Code.userAuthenticationRequired } ?? false
    }
}
