//
//  KeychainTests.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 9/10/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
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
		
		let value = "Value: \(UUID().uuidString)"
		let value2 = "Value2: \(UUID().uuidString)"
		let service = "Service: \(UUID().uuidString)"
		let account = "Account: \(UUID().uuidString)"
		
		guard let data = value.data(using: .utf8, allowLossyConversion: false), let data2 = value2.data(using: .utf8, allowLossyConversion: false) else {
			XCTFail()
			return
		}
		do {
			// Write to keychain and read back 'value'
			try Keychain.write(data: data, service: service, account: account)
			let retrievedValue = String(data: try Keychain.read(service: service, account: account), encoding: .utf8)
			XCTAssert(value == retrievedValue)
			
			// Update 'value' with 'value2' and read it back
			try Keychain.write(data: data2, service: service, account: account)
			let retrievedValue2 = String(data: try Keychain.read(service: service, account: account), encoding: .utf8)
			XCTAssert(value2 == retrievedValue2)
		}
		catch {
			XCTFail(error.localizedDescription)
		}
		
		// Delete from keychain
		do {
			try Keychain.delete(service: service, account: account)
			let _ = try Keychain.read(service: service, account: account)
		}
		catch (error: KeychainError.itemNotFound) {
			// Expected
		}
		catch {
			XCTFail()
		}
	}
}
