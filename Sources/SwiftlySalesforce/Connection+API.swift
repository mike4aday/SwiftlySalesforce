import Foundation

public extension Connection {
    
    func limits() async throws -> [String: Limit] {
        return try await request(service: Resource.Limits())
    }
    
    func query<T: Decodable>(soql: String, batchSize: Int? = nil) async throws -> QueryResult<T> {
        return try await request(service: Resource.Query.Run(soql: soql, batchSize: batchSize))
    }
    
    func query(soql: String, batchSize: Int? = nil) async throws -> QueryResult<Record> {
        return try await request(service: Resource.Query.Run(soql: soql, batchSize: batchSize))
    }
    
    func myRecords<T: Decodable>(type: String, fields: [String]? = nil, limit: Int? = nil, batchSize: Int? = nil) async throws -> QueryResult<T> {
        return try await request(service: Resource.Query.MyRecords(type: type, fields: fields, limit: limit, batchSize: batchSize))
    }
    
    func myRecords(type: String, fields: [String]? = nil, limit: Int? = nil, batchSize: Int? = nil) async throws -> QueryResult<Record> {
        return try await request(service: Resource.Query.MyRecords(type: type, fields: fields, limit: limit, batchSize: batchSize))
    }
    
    func search(sosl: String) async throws -> [Record] {
        return try await request(service: Resource.Search(sosl: sosl))
    }
    
    func insert<T: Encodable>(type: String, fields: [String: T]) async throws -> String {
        return try await request(service: Resource.SObjects.Create(type: type, fields: fields))
    }
    
    func read<T: Decodable>(type: String, id: String, fields: [String]? = nil) async throws -> T {
        return try await request(service: Resource.SObjects.Read(type: type, id: id, fields: fields))
    }
    
    func read(type: String, id: String, fields: [String]? = nil) async throws -> Record {
        return try await request(service: Resource.SObjects.Read(type: type, id: id, fields: fields))
    }
    
    func update<T: Encodable>(type: String, id: String, fields: [String: T]) async throws -> Void {
        return try await request(service: Resource.SObjects.Update(type: type, id: id, fields: fields))
    }
    
    func delete(type: String, id: String) async throws -> Void {
        return try await request(service: Resource.SObjects.Delete(type: type, id: id))
    }
    
    func describe(type: String) async throws -> ObjectDescription {
        return try await request(service: Resource.SObjects.Describe(type: type))
    }
    
    func describeGlobal() async throws -> [ObjectDescription] {
        return try await request(service: Resource.SObjects.DescribeGlobal())
    }
    
    func identity() async throws -> Identity {
        return try await request(service: IdentityService())
    }
    
    func apex<T: Decodable>(
        method: String? = nil,
        path: String,
        queryItems: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeoutInterval: TimeInterval = URLRequest.defaultTimeoutInterval
    ) async throws -> T {
        
        let service = ApexService<T>(path: path, method: method, queryItems: queryItems, headers: headers, body: body, timeoutInterval: timeoutInterval)
        return try await request(service: service)
    }
}
