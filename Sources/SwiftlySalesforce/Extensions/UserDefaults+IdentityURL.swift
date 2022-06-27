import Foundation

internal extension UserDefaults {
    
    var userIdentifier: UserIdentifier? {
        get {
            guard let identityURL = url(forKey: #function) else {
                return nil
            }
            return UserIdentifier(rawValue: identityURL)
        }
        set {
            guard let user = newValue else {
                return removeObject(forKey: #function)
            }
            set(user.rawValue, forKey: #function)
        }
    }
}
