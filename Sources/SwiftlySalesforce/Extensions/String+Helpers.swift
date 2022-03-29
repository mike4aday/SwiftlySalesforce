import Foundation

public extension String {
    
    init?(byPercentEncoding params: Dictionary<String, String>){
        var comps = URLComponents()
        comps.queryItems = .init(params)
        if let s = comps.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B") {
            self = s
        }
        else {
            return nil
        }
    }
    
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }
}
