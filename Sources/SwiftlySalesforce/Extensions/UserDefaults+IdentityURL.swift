import Foundation

internal extension UserDefaults {
    
    var userIdentifier: UserIdentifier? {
        get {
            return url(forKey: #function)
        }
        set {
            guard let user = newValue else {
                return removeObject(forKey: #function)
            }
            set(user, forKey: #function)
        }
    }
}
