/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

public extension ConnectedApp {
    
    /// Performs a query
    /// - Parameters:
    ///   - soql: A SOQL query.
    ///   - batchSize: A numeric value that specifies the number of records returned for a query request. Child objects count toward the number of records for the batch size. For example, in relationship queries, multiple child objects are returned per parent row returned. The default is 2,000; the minimum is 200, and the maximum is 2,000. There is no guarantee that the requested batch size is the actual batch size. Changes are made as necessary to maximize performance.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher of query results.
    /// # Reference
    /// - [Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_query.htm)
    /// - [SOQL and SOSL Reference](https://developer.salesforce.com/docs/atlas.en-us.232.0.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_sosl_intro.htm)
    func query(
        soql: String,
        batchSize: Int = 2000,
        session: URLSession = .shared,
        allowsLogin: Bool = true
    ) -> AnyPublisher<QueryResult<Record>, Error> {
    
        let service = QueryService(.execute(soql: soql, batchSize: batchSize))
        return go(service: service, session: session, allowsLogin: allowsLogin)
    }
    
    /// Retrieves the next page of query results.
    ///
    /// If the initial query returns only part of the results, the `QueryResult` will contain a value in `nextRecordsPath` which can be used as the `path` argument for this method.
    /// - Parameters:
    ///   - path: The path to the next page of query results, as returned by the previous call to `query` or `nextResultPage`.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher of query results.
    /// # Reference
    /// [Execute a SOQL Query](https://developer.salesforce.com/docs/atlas.en-us.232.0.api_rest.meta/api_rest/dome_query.htm)
    ///
    func nextResultPage(
        at path: String,
        session: URLSession = .shared,
        allowsLogin: Bool = true
    ) -> AnyPublisher<QueryResult<Record>, Error> {
    
        let service = QueryService(.nextResultPage(at: path))
        return go(service: service, session: session, allowsLogin: allowsLogin)
    }
    
    /// Queries all records of the specified type which are owned by the user.
    /// - Parameters:
    ///   - type: Type of record (e.g. `Account`, `Contact` or `MyCustomObject__c`).
    ///   - fields: Fields to retrieve. If nil, then all fields will be retrieved.
    ///   - limit: The maximum number of rows to return.
    ///   - batchSize: The batch size for a query determines the number of rows that are returned in the query results.
    ///   - user: Specified user, or nil to use the last authenticated user.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Publisher of `QueryResult` of `Record` instances.
    func myRecords(
        type: String,
        fields: [String]? = nil,
        limit: Int? = nil,
        batchSize: Int = 2000,
        user: UserIdentifier? = nil,
        session: URLSession = .shared,
        allowsLogin: Bool = true
    ) -> AnyPublisher<QueryResult<Record>, Error> {
    
        let allFields = "FIELDS(ALL)"
        
        var fieldSpec = ""
        if let fields = fields {
            fieldSpec = fields.joined(separator: ",")
        }
        else {
            fieldSpec = allFields
        }
        
        var limitSpec = ""
        if let limit = limit {
            limitSpec = "LIMIT \(limit)"
        }
        else if fieldSpec == allFields {
            limitSpec = "LIMIT 200"
        }
        
        return credentialManager.getCredential(for: user, allowsLogin: allowsLogin)
            .map { "SELECT \(fieldSpec) FROM \(type) WHERE OwnerId = '\($0.userID)' \(limitSpec)" }
            .flatMap { query(soql: $0, batchSize: batchSize, session: session, allowsLogin: allowsLogin) }
            .eraseToAnyPublisher()
    }
}
