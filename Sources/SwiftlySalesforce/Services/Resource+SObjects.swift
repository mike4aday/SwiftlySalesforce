import Foundation

public extension Resource {
    
    struct SObjects {
                
        public struct Create: DataService {
                                    
            let type: String
            let encode: () throws -> Data
            
            @available(*, deprecated, message: "Call init(type: String, encode: () throws -> Data) instead.")
            public init<T>(type: String, fields: [String: T]) where T: Encodable {
                self.type = type
                self.encode = { try JSONEncoder().encode(fields) }
            }
            
            public init(type: String, encode: @escaping () throws -> Data) {
                self.type = type
                self.encode = encode 
            }
            
            public func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.post
                let path = Resource.path(for: "sobjects/\(type)")
                let body = try encode()
                return try URLRequest(credential: credential, method: method, path: path, body: body)
            }
            
            public func transform(data: Data) throws -> String {
                let result = try JSONDecoder(dateFormatter: .salesforce(.long)).decode(Result.self, from: data)
                return result.id
            }
            
            private struct Result: Decodable {
                var id: String
            }
        }
        
        //MARK: - Read record -
        public struct Read<D: Decodable>: DataService {
            
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
        public struct Update<E: Encodable>: DataService {
                        
            public typealias Output = Void
            
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
        public struct Delete: DataService {
            
            public typealias Output = Void
            
            let type: String
            let id: String
                        
            public func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.delete
                let path = Resource.path(for: "sobjects/\(type)/\(id)")
                return try URLRequest(credential: credential, method: method, path: path)
            }
        }
        
        //MARK: - Describe SObject -
        public struct Describe: DataService {
            
            public typealias Output = ObjectDescription
            
            let type: String
                        
            public func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.get
                let path = Resource.path(for: "sobjects/\(type)/describe")
                return try URLRequest(credential: credential, method: method, path: path)
            }
        }
        
        //MARK: - Describe all SObjects -
        public struct DescribeGlobal: DataService {
                        
            public func createRequest(with credential: Credential) throws -> URLRequest {
                let method = HTTP.Method.get
                let path = Resource.path(for: "sobjects")
                return try URLRequest(credential: credential, method: method, path: path)
            }
            
            public func transform(data: Data) throws -> [ObjectDescription] {
                struct Result: Decodable {
                    var sobjects: [ObjectDescription]
                }
                let result = try JSONDecoder(dateFormatter: .salesforce(.long)).decode(Result.self, from: data)
                return result.sobjects
            }
        }
    }
}
