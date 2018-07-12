//
//  KeychainTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//

import XCTest
@testable import SwiftlySalesforce

class KeychainTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testThatItReadsWritesAndDeletes() {
		
		// Given
		let value: [String: Any] = [
			"accessToken": "\(UUID().uuidString)",
			"refreshToken": "\(UUID().uuidString)",
			"instanceURL": URL(string: "https://www.salesforce.com")!
		]
		let value2: [String: Any] = [
			"accessToken": "\(UUID().uuidString)",
			"refreshToken": "\(UUID().uuidString)",
			"instanceURL": URL(string: "https://www.mydomain.com/")!
		]
		let service = "Service: \(UUID().uuidString)"
		let account = "Account: \(UUID().uuidString)"
		let data = NSKeyedArchiver.archivedData(withRootObject: value)
		let data2 = NSKeyedArchiver.archivedData(withRootObject: value2)
		
		do {
			// Write to keychain and read back 'value'
			try Keychain.write(data: data, service: service, account: account)
			guard let keychainData = try? Keychain.read(service: service, account: account),
			let keychainDict = NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? [String: Any],
				keychainDict["accessToken"] as? String == value["accessToken"] as? String,
				keychainDict["refreshToken"] as? String == value["refreshToken"] as? String,
				keychainDict["instanceURL"] as? URL == value["instanceURL"] as? URL else {
					XCTFail()
					return
			}

			// Update 'value' with 'value2' and read it back
			try Keychain.write(data: data2, service: service, account: account)
			guard let keychainData2 = try? Keychain.read(service: service, account: account),
				let keychainDict2 = NSKeyedUnarchiver.unarchiveObject(with: keychainData2) as? [String: Any],
				keychainDict2["accessToken"] as? String == value2["accessToken"] as? String,
				keychainDict2["refreshToken"] as? String == value2["refreshToken"] as? String,
				keychainDict2["instanceURL"] as? URL == value2["instanceURL"] as? URL else {
					XCTFail()
					return
			}
		}
		catch {
			XCTFail(error.localizedDescription)
		}
		
		// Delete from keychain
		guard let _ = try? Keychain.delete(service: service, account: account) else {
			XCTFail()
			return
		}
		
		// Make sure it's gone
		do {
			let _ = try Keychain.read(service: service, account: account)
		}
		catch (error: Keychain.Error.itemNotFound) {
			// Expected
		}
		catch {
			XCTFail()
		}
	}
}
