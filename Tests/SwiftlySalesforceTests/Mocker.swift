import Foundation

struct Mocker {
    
    static let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .formatted(.salesforceDateTimeFormatter)
        return d
    }()
}
