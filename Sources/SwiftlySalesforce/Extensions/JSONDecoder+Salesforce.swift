import Foundation

public extension JSONDecoder {
    
    static let salesforce = JSONDecoder(dateFormatter: .salesforce(.long))

    convenience init(dateDecodingStrategy: DateDecodingStrategy) {
        self.init()
        self.dateDecodingStrategy = dateDecodingStrategy
    }
    
    convenience init(dateFormatter: DateFormatter) {
        self.init(dateDecodingStrategy: .formatted(dateFormatter))
    }
}
