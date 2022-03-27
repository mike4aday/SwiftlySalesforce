import Foundation

extension URLSession {
    
    static func mock(withLoadingHandler: ((URLRequest) -> (HTTPURLResponse, Data?, Error?))?) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.loadingHandler = withLoadingHandler
        return URLSession.init(configuration: configuration)
    }
    
    static func mock(responseBody: Data, statusCode: Int) -> URLSession {
        let loadingHandler: ((URLRequest) -> (HTTPURLResponse, Data?, Error?))? = { request in
            let metadata = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (metadata, responseBody, nil)
        }
        return mock(withLoadingHandler: loadingHandler)
    }
    
    static func mock(error: Error, statusCode: Int) -> URLSession {
        let loadingHandler: ((URLRequest) -> (HTTPURLResponse, Data?, Error?))? = { request in
            let metadata = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (metadata, nil, error)
        }
        return mock(withLoadingHandler: loadingHandler)
    }
}
