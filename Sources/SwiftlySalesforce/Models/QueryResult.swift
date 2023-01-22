import Foundation

/// Holds the result of a SOQL query.
/// See [Execute a SOQL Query](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm).
public struct QueryResult<T: Decodable> {
    
    public let totalSize: Int
    public let isDone: Bool
    public let records: [T]
    public let nextRecordsPath: String?
}

extension QueryResult: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case totalSize
        case isDone = "done"
        case records
        case nextRecordsPath = "nextRecordsUrl"
    }
}

public extension QueryResult {
    
    // Useful for testing/mocking
    init(records: [T], totalSize: Int, isDone: Bool, nextRecordsPath: String?) {
        self.records = records
        self.totalSize = totalSize
        self.isDone = isDone
        self.nextRecordsPath = nextRecordsPath
    }
}
