//
//  Salesforce+Authorization.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/18/18.
//

import Foundation
import SafariServices
import PromiseKit

extension Salesforce {
	
	public func authorize() -> Promise<Authorization> {
		if let promise = self.authPromise, promise.isPending {
			return promise
		}
		else {
			let promise = Promise<URL> { seal in
				let authURL = try configuration.authorizationURL()
				let scheme = configuration.callbackURL.scheme
				let session = SFAuthenticationSession(url: authURL, callbackURLScheme: scheme) { url, error in
					seal.resolve(url, error)
				}
				guard session.start() else {
					throw AuthorizationError.sessionStartFailure
				}
			}.map { url in
				return try Authorization(withRedirectURL: url)
			}
			self.authPromise = promise
			return promise
		}
	}
}

extension Salesforce {
	
	enum AuthorizationError: Error {
		case sessionStartFailure
	}
}
