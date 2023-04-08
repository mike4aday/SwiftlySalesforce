import Foundation

extension Resource {
    
    struct Query {
        
        struct Run<T: Decodable>: DataService {
            
            typealias Output = QueryResult<T>
            
            let soql: String
            
            var batchSize: Int? = nil
            
            func createRequest(with credential: Credential) throws -> URLRequest {
                let path = Resource.path(for: "query")
                let queryItems = ["q": soql]
                let headers = batchSize.map { ["Sforce-Query-Options" : "batchSize=\($0)"] }
                return try URLRequest(credential: credential, path: path, queryItems: queryItems, headers: headers)
            }
        }
        
        struct NextResultsPage<T: Decodable>: DataService {
            
            typealias Output = QueryResult<T>
            
            let path: String
                        
            func createRequest(with credential: Credential) throws -> URLRequest {
                return try URLRequest(credential: credential, path: path)
            }
        }
        
        struct MyRecords<T: Decodable>: DataService {
            
            typealias Output = QueryResult<T>
            
            let type: String
            
            var fields: [String]? = nil
            var limit: Int? = nil
            var batchSize: Int? = nil
            
            func createRequest(with credential: Credential) throws -> URLRequest {
                let ownerId = credential.userIdentifier.userID
                let fieldSpec = fields.map { $0.joined(separator: ",") } ?? "FIELDS(ALL)"
                let limitSpec = limit.map { "LIMIT \($0)" } ?? fields.map { _ in "" } ?? "LIMIT 200"
                let soql = "SELECT \(fieldSpec) FROM \(type) WHERE OwnerId = '\(ownerId)' \(limitSpec)"
                return try Resource.Query.Run<T>(soql: soql, batchSize: batchSize).createRequest(with: credential)
            }
        }
    }
}
