import Foundation

public extension Connection {
    
    /// Retrieves information about limits in your org. 
    /// For each limit, this method returns the maximum allocation and the remaining allocation based on usage.
    /// 
    /// [Limits](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm)
    ///
    /// - Returns: A dictionary of ``Limit`` instances.
    ///
    func limits() async throws -> [String: Limit] {
        return try await request(service: Resource.Limits())
    }
    
    /// Performs a query.
    ///
    /// - [Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm)
    /// - [SOQL and SOSL Reference](https://developer.salesforce.com/docs/atlas.en-us.232.0.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_sosl_intro.htm)
    ///
    /// - Parameters:
    ///     - soql: A SOQL query string.
    ///     - batchSize: A numeric value that specifies the number of records returned for a query request.
    /// 
    /// - Returns: ``QueryResult``
    ///
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
    
    /// Searches for a string in Salesforce record fields
    ///
    /// [SOQL and SOSL Reference](https://developer.salesforce.com/docs/atlas.en-us.232.0.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_sosl_intro.htm)
    ///
    /// - Parameters:
    ///     - sosl: A SOSL query string.
    ///
    /// - Returns:
    ///     - An array of records that match the search criteria.
    ///
    func search(sosl: String) async throws -> [Record] {
        return try await request(service: Resource.Search(sosl: sosl))
    }
    
    /// Inserts a Salesforce record
    ///
    /// - Parameters:
    ///     - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///     - fields: Dictionary of fields names and values to insert.
    ///
    /// - Returns: Publisher that emits the ID of the successfully-inserted record, or an error.
    ///
    func insert<T: Encodable>(type: String, fields: [String: T]) async throws -> String {
        let encode = { try JSONEncoder().encode(fields) }
        return try await request(service: Resource.SObjects.Create(type: type, encode: encode))
    }
    
    func insert<T: Encodable>(type: String, record: T, encoder: JSONEncoder = JSONEncoder()) async throws -> String {
        let encode = { try encoder.encode(record) }
        return try await request(service: Resource.SObjects.Create(type: type, encode: encode))
    }
    
    func insert<T: Encodable, CodingKeys>(type: String, record: T, keysToEncode: [CodingKeys]?) async throws -> String {
        let encode = { () throws -> Data in
            let encoder = JSONEncoder()
            if let keys = keysToEncode {
                encoder.userInfo[.keysToEncode] = keys
            }
            return try encoder.encode(record)
        }
        return try await request(service: Resource.SObjects.Create(type: type, encode: encode))
    }
    
    func insert(type: String, body: Data) async throws -> String {
        let encode = { () throws -> Data in body }
        return try await request(service: Resource.SObjects.Create(type: type, encode: encode))
    }
    
    /// Retrieves a Salesforce record.
    ///
    /// [Working with Records](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/using_resources_working_with_records.htm)
    ///
    /// - Parameters:
    ///     - type: Type of record (e.g. "Account", "Contact" or "MyCustomObject__c").
    ///     - id: Unique ID of the record; 15 or 18 characters.
    ///     - fields: Fields to retrieve. If nil, then all fields will be retrieved.
    ///
    /// - Returns: A Salesforce record.
    ///
    /// - Throws: ``ResponseError`` if the record can't be found or if the request can't be completed.
    ///
    func read<T: Decodable>(type: String, id: String, fields: [String]? = nil) async throws -> T {
        return try await request(service: Resource.SObjects.Read(type: type, id: id, fields: fields))
    }
    
    func read(type: String, id: String, fields: [String]? = nil) async throws -> Record {
        return try await request(service: Resource.SObjects.Read(type: type, id: id, fields: fields))
    }
    
    /// Updates a Salesforce record
    ///
    /// - Parameters:
    ///     - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///     - id: Unique ID of the record; 15 or 18 characters.
    ///     - fields: Dictionary of fields names and values to update.
    ///
    /// - Returns: Void; no return value.
    ///
    func update<T: Encodable>(type: String, id: String, fields: [String: T]) async throws -> Void {
        return try await request(service: Resource.SObjects.Update(type: type, id: id, fields: fields))
    }
    
    /// Deletes a Salesforce record
    ///
    /// - Parameters:
    ///     - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///     - id: Unique ID of the record; 15 or 18 characters.
    ///
    /// - Returns: Void; no return value.
    ///
    func delete(type: String, id: String) async throws -> Void {
        return try await request(service: Resource.SObjects.Delete(type: type, id: id))
    }
    
    /// Retrieves metadata about a Salesforce object.
    ///
    /// [sObject Describe](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm)
    ///
    /// - Parameters:
    ///     - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///
    /// - Returns: An ``ObjectDescription`` instance.
    ///
    func describe(type: String) async throws -> ObjectDescription {
        return try await request(service: Resource.SObjects.Describe(type: type))
    }
    
    /// Describes all accessible objects in the user's Salesforce org.
    ///
    /// [sObject Describe](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_describe.htm)
    ///
    /// - Returns: An array of ``ObjectDescription`` instances.
    ///
    func describeGlobal() async throws -> [ObjectDescription] {
        return try await request(service: Resource.SObjects.DescribeGlobal())
    }
    
    /// Gets information about the current user
    ///
    /// - Returns: An ``Identity`` instance.
    ///
    func identity() async throws -> Identity {
        return try await request(service: IdentityService())
    }
    
    /// Calls an Apex class exposed as a REST service.
    ///
    /// [Introduction to Apex REST](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_intro.htm)
    ///
    /// - Parameters:
    ///     - method: Optional, HTTP method to use; if `nil` then GET will be used in the request.
    ///     - path: Path to the Apex REST service, as defined in the `urlMapping` of the `@RestResource` annotation on the target class.
    ///     - queryItems: Optional query items to include in the request.
    ///     - headers: Optional `HTTP` headers to include in the request.
    ///     - body: Request body for a `POST` , `PATCH` or `PUT`  request.
    ///     - timeoutInterval: request timeout interval, in seconds.
    ///
    /// - Returns: The `Decodable` return value from the Apex class.
    ///
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
