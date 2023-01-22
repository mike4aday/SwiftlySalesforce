import Foundation

/// Holds the result of a SOQL query.
/// See [Execute a SOQL Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm).
public struct QueryResult<T: Decodable>: Decodable {
    
    public let totalSize: Int
    public let isDone: Bool
    public let records: [T]
    public let nextRecordsPath: String?
    
    enum CodingKeys: String, CodingKey {
        case totalSize
        case isDone = "done"
        case records
        case nextRecordsPath = "nextRecordsUrl"
    }
}

//public extension QueryResult {
//    
//    // Useful for mocking/testing
//    init(totalSize: Int, isDone: Bool, records: [T], nextRecordsPath: String?) {
//        self.totalSize = totalSize
//        self.isDone = isDone
//        self.records = records
//        self.nextRecordsPath = nextRecordsPath
//    }
//}
