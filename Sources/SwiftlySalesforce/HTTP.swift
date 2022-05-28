import Foundation

public struct HTTP {
    
    public struct Method {
        public static let get = "GET"
        public static let delete = "DELETE"
        public static let post = "POST"
        public static let patch = "PATCH"
        public static let head = "HEAD"
        public static let put = "PUT"
    }
    
    public struct MIMEType {
        public static let json = "application/json;charset=UTF-8"
        public static let formUrlEncoded = "application/x-www-form-urlencoded;charset=utf-8"
    }
    
    public struct Header {
        public static let accept = "Accept"
        public static let contentType = "Content-Type"
    }
}
