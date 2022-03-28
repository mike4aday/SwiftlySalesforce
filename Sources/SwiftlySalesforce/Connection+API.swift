import Foundation

public extension Connection {
    
    /// Queries Salesforce for the
    /// - Returns: A dictionary of ``Limit`` instances
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
    
    /// Gets information about the current user
    /// - Returns: An ``Identity`` instance.
    func identity() async throws -> Identity {
        return try await request(service: IdentityService())
    }
    
    /// Represents a call to an Apex class exposed as a REST service.
    ///
    /// You can expose your Apex class and methods so that external applications can access your code and your application through the REST architecture. This is done by defining your Apex class with the @RestResource annotation to expose it as a REST resource. Similarly, add annotations to your methods to expose them through REST. For example, you can add the @HttpGet annotation to your method to expose it as a REST resource that can be called by an HTTP GET request.
    /// - Parameters:
    ///   - method: Optional, HTTP method to use; if `nil` then GET will be used in the request.
    ///   - path: Path to the Apex REST service, as defined in the `urlMapping` of the `@RestResource` annotation on the target class.
    ///   - queryItems: Optional query items to include in the request.
    ///   - headers: Optional `HTTP` headers to include in the request.
    ///   - body: Request body for a `POST` , `PATCH` or `PUT`  request.
    ///   - timeoutInterval: request timeout interval, in seconds.
    /// - Returns: The `Decodable` return value from the Apex class.
    ///
    /// See [Introduction to Apex REST](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_intro.htm).
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
