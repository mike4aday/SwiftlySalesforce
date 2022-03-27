import Foundation

extension Resource {
    
    struct Search: DataService {
                    
        typealias Output = [Record]
            
        let sosl: String
        
        func createRequest(with credential: Credential) throws -> URLRequest {
            let path = Resource.path(for: "search")
            let queryItems = ["q": sosl]
            return try URLRequest(credential: credential, path: path, queryItems: queryItems)
        }
        
        func transform(data: Data) throws -> [Record] {
            struct SearchResult: Decodable {
                var searchRecords: [Record]
            }
            let decoder = JSONDecoder(dateFormatter: .salesforce(.long))
            let searchResult = try decoder.decode(SearchResult.self, from: data)
            return searchResult.searchRecords
        }
    }
}

