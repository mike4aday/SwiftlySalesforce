import Foundation

struct ResponseError: Error {
    
    var code: String? = nil
    var message: String? = nil
    var fields: [String]? = nil
    let metadata: HTTPURLResponse
    
    private let na = "N/A" // 'Not Applicable' or 'Not Available'
}

extension ResponseError: LocalizedError {
    
    public var errorDescription: String? {
        return NSLocalizedString(message ?? na, comment: code ?? na)
    }
}

extension ResponseError: CustomDebugStringConvertible {
    
    var debugDescription: String {
        let na = "N/A" // 'Not Applicable' or 'Not Available'
        let fieldStr = fields?.joined(separator: ", ") ?? na
        return "Salesforce response error. Code: \(code ?? na). Message: \(message ?? na). Fields: \(fieldStr). HTTP Status Code: \(metadata.statusCode))"
    }
}
