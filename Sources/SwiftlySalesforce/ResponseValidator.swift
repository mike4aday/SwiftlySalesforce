import Foundation

public protocol ResponseValidator {
    
    typealias Response<Body> = (body: Body, metadata: HTTPURLResponse)
    
    associatedtype Body = Data
    func validate(response: Response<Body>) throws
    func checkAuthenticationRequired(response: Response<Body>) throws
    func checkError(response: Response<Body>) throws
}

public extension ResponseValidator {
    
    func validate(response: Response<Body>) throws {
        try checkAuthenticationRequired(response: response)
        try checkError(response: response)
    }
    
    func checkAuthenticationRequired(response: Response<Body>) throws {
        guard 401 != response.metadata.statusCode else {
            throw URLError(.userAuthenticationRequired)
        }
    }
    
    func checkError(response: Response<Body>) throws {
        guard (200..<300).contains(response.metadata.statusCode) else {
            throw ResponseError(metadata: response.metadata)
        }
    }
    
    func checkError(response: Response<Body>) throws where Body == Data {
        guard (200..<300).contains(response.metadata.statusCode) else {
            if let dto = ResponseErrorDTO(from: response.body) {
                throw ResponseError(code: dto.errorCode, message: dto.message, fields: dto.fields, metadata: response.metadata)
            }
            else if let str = String(data: response.body) {
                throw ResponseError(message: str, metadata: response.metadata)
            }
            else {
                throw ResponseError(metadata: response.metadata)
            }
        }
    }
}

fileprivate struct ResponseErrorDTO: Decodable {
    
    let errorCode: String
    let message: String
    let fields: [String]?
    
    init?(from data: Data) {
        guard let dto =
                (try? JSONDecoder.salesforce.decode([ResponseErrorDTO].self, from: data).first)
                ?? (try? JSONDecoder.salesforce.decode(ResponseErrorDTO.self, from: data)) else {
            return nil
        }
        self = dto
    }
}
