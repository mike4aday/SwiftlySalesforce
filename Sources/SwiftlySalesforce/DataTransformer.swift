import Foundation

public protocol DataTransformer {
    
    associatedtype Output
    func transform(data: Data) throws -> Output
}

public extension DataTransformer {
    
    func transform(data: Data) throws -> Output where Output: Decodable {
        try JSONDecoder.salesforce.decode(Output.self, from: data)
    }
    
    func transform(data: Data) throws -> Output where Output == Data {
        return data
    }
    
    func transform(data: Data) throws -> Output where Output == String {
        return String(data: data) ?? ""
    }
    
    func transform(data: Data) throws -> Output where Output == Void {
        return
    }
}
