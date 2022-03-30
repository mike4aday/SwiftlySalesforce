import Foundation

public extension Connection {
    
    /// Retrieves information about limits in your org. 
    /// For each limit, this method returns the maximum allocation and the remaining allocation based on usage.
    /// 
    /// [Limits](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm)
    ///
    /// - Returns: A dictionary of ``Limit`` instances
    func limits() async throws -> [String: Limit] {
        return try await request(service: Resource.Limits())
    }
    
    /// Performs a query.
    ///
    /// - [Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm)
    /// - [SOQL and SOSL Reference](https://developer.salesforce.com/docs/atlas.en-us.232.0.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_sosl_intro.htm)
    ///
    /// - Parameters:
    ///   - soql: A SOQL query.
    ///   - batchSize: A numeric value that specifies the number of records returned for a query request.
    /// 
    /// - Returns: A `QueryResult`.
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
    /// See [Introduction to Apex REST](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_intro.htm) in the Salesforce documentation.
    ///
    /// - Parameters:
    ///   - method: Optional, HTTP method to use; if `nil` then GET will be used in the request.
    ///   - path: Path to the Apex REST service, as defined in the `urlMapping` of the `@RestResource` annotation on the target class.
    ///   - queryItems: Optional query items to include in the request.
    ///   - headers: Optional `HTTP` headers to include in the request.
    ///   - body: Request body for a `POST` , `PATCH` or `PUT`  request.
    ///   - timeoutInterval: request timeout interval, in seconds.
    /// - Returns: The `Decodable` return value from the Apex class.
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
