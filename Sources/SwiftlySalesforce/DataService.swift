import Foundation

public protocol DataService: RequestCreator & ResponseValidator & DataTransformer where Body == Data {
    
    func request(with: Credential, using: URLSession) async throws -> Output
}

public extension DataService {
    
    func request(with credential: Credential, using session: URLSession = .shared) async throws -> Output {
        let request = try createRequest(with: credential)
        guard let response = try await session.data(for: request) as? Response<Data> else {
            throw URLError(.badServerResponse)
        }
        try validate(response: response)
        return try transform(data: response.0)
    }
}
