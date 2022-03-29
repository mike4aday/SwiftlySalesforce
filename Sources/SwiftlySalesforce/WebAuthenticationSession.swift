import Foundation
import AuthenticationServices

@MainActor
struct WebAuthenticationSession {
    
    static let shared = WebAuthenticationSession()
    
    private init() {
        // Can't instantiate
    }
    
    func start(url: URL, callbackURLScheme: String) async throws -> URL {
        let contextProvider = ContextProvider()
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { (url, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    guard let url = url else {
                        return continuation.resume(throwing: StateError("Invalid state"))
                    }
                    continuation.resume(returning: url)
                }
            }
            session.prefersEphemeralWebBrowserSession = false // 'true' can cause presentation problems
            session.presentationContextProvider = contextProvider
            guard session.canStart, session.start() else {
                return continuation.resume(throwing: StateError("Failed to start web authentication session"))
            }
        }
    }
}

fileprivate class ContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
