import Foundation

public struct HTTP {
    
    struct Method {
        static let get = "GET"
        static let delete = "DELETE"
        static let post = "POST"
        static let patch = "PATCH"
        static let head = "HEAD"
        static let put = "PUT"
    }
    
    struct MIMEType {
        static let json = "application/json;charset=UTF-8"
        static let formUrlEncoded = "application/x-www-form-urlencoded;charset=utf-8"
    }
    
    struct Header {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }
}
