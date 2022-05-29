import Foundation

public extension Resource {
    
    struct SObjects {
                
        struct Create: DataService {
                                    
            let type: String
            let body: Data
            
            @available(*, deprecated, message: "Call init(type: String, body: Data) instead.")
            init<T>(type: String, fields: [String: T]) throws where T: Encodable {
                self.type = type
                self.body = try JSONEncoder().encode(fields)
            }
            
            init(type: String, body: Data) {
                self.type = type
                self.body = body
            }
            
            func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.post
                let path = Resource.path(for: "sobjects/\(type)")
                return try URLRequest(credential: credential, method: method, path: path, body: self.body)
            }
            
            func transform(data: Data) throws -> String {
                let result = try JSONDecoder(dateFormatter: .salesforce(.long)).decode(Result.self, from: data)
                return result.id
            }
            
            private struct Result: Decodable {
                var id: String
            }
        }
        
        //MARK: - Read record -
        struct Read<D: Decodable>: DataService {
            
            public typealias Output = D
            
            let type: String
            let id: String
            
            var fields: [String]? = nil

            public func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.get
                let path = Resource.path(for: "sobjects/\(type)/\(id)")
                let queryItems = fields.map { ["fields": $0.joined(separator: ",")] }
                return try URLRequest(credential: credential, method: method, path: path, queryItems: queryItems)
            }
        }
        
        //MARK: - Update record -
        struct Update<E: Encodable>: DataService {
                        
            typealias Output = Void
            
            let type: String
            let id: String
            let fields: [String: E]
                        
            public func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.patch
                let encoder = JSONEncoder()
                let path = Resource.path(for: "sobjects/\(type)/\(id)")
                let body = try encoder.encode(fields)
                return try URLRequest(credential: credential, method: method, path: path, body: body)
            }
        }
        
        //MARK: - Delete record -
        struct Delete: DataService {
            
            typealias Output = Void
            
            let type: String
            let id: String
                        
            func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.delete
                let path = Resource.path(for: "sobjects/\(type)/\(id)")
                return try URLRequest(credential: credential, method: method, path: path)
            }
        }
        
        //MARK: - Describe SObject -
        struct Describe: DataService {
            
            typealias Output = ObjectDescription
            
            let type: String
                        
            func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.get
                let path = Resource.path(for: "sobjects/\(type)/describe")
                return try URLRequest(credential: credential, method: method, path: path)
            }
        }
        
        //MARK: - Describe all SObjects -
        struct DescribeGlobal: DataService {
                        
            func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.get
                let path = Resource.path(for: "sobjects")
                return try URLRequest(credential: credential, method: method, path: path)
            }
            
            func transform(data: Data) throws -> [ObjectDescription] {
                struct Result: Decodable {
                    var sobjects: [ObjectDescription]
                }
                let result = try JSONDecoder(dateFormatter: .salesforce(.long)).decode(Result.self, from: data)
                return result.sobjects
            }
        }
    }
}
