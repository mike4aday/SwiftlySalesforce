import Foundation

struct OAuthError: Error, Decodable {
    
    let code: String
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "error"
        case message = "error_description"
    }
    
    init(code: String, message: String? = nil) {
        self.code = code
        self.message = message 
    }
    
    init?(fromPercentEncodedString: String) {
        let comps = URLComponents(percentEncodedQuery: fromPercentEncodedString)
        guard let code = comps.queryItems?[CodingKeys.code.rawValue] else {
            return nil
        }
        self.code = code
        self.message = comps.queryItems?[CodingKeys.message.rawValue]
    }
}
