
import Foundation

// Adapted from https://augmentedcode.io/2019/05/26/testing-networking-code-with-custom-urlprotocol-on-ios/
final class MockURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    static var loadingHandler: ((URLRequest) -> (HTTPURLResponse, Data?, Error?))?
    
    override func startLoading() {
        
        guard let handler = MockURLProtocol.loadingHandler else {
            return
        }
        let (response, data, error) = handler(request)
        if let data = data {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        else {
            client?.urlProtocol(self, didFailWithError: error!)
        }
    }
    
    override func stopLoading() {
        // Do nothing
    }
}
