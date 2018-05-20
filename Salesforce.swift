//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import SafariServices

public class Salesforce {
	
	public var configuration: Configuration
	
	internal var authPromise: Promise<Authorization>?
	internal var authSession: SFAuthenticationSession?
	
	public init(configuration: Configuration) {
		self.configuration = configuration
	}
}
