//
//  Salesforce+CRUDTests.swift
//  SwiftlySalesforceTests
//
//  Created by Michael Epstein on 11/17/19.
//

import XCTest
import Combine
@testable import SwiftlySalesforce

class Salesforce_CRUDTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
    }

    override func tearDown() {
    }

    // Integration test
    func testThatItInsertsUpdatesRetrievesAndDeletes() {
        
        let acctName = UUID().uuidString
        let sfdc = Util.salesforce

        let pub = sfdc
            .insert(object: "Account", fields: ["Name": acctName, "BillingCity": "Omaha"] as [String: Encodable?])
            .flatMap { (id) -> AnyPublisher<SObject, Error> in
                sfdc.retrieve(object: "Account", id: id, fields: ["Name", "BillingCity"])
            }
        .flatMap { (record) -> AnyPublisher<Void, Error> in
                
            XCTAssertEqual(record.string(forField: "Name"), acctName)
            XCTAssertEqual(record.string(forField: "BillingCity"), "Omaha")
            XCTAssertNotNil(record.id)
            
            return sfdc.update(object: "Account", id: record.id!, fields: ["BillingCity": "Los Angeles"])
            .flatMap { _ in
                return sfdc.retrieve(object: "Account", id: record.id!)
            }
            .flatMap { (record) -> AnyPublisher<Void, Error> in
                XCTAssertEqual("Los Angeles", record.string(forField: "BillingCity"))
                return sfdc.delete(record: record)
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
        
            
        let exp = expectation(description: "Insert, retrieve and delete account record")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { (_) in
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
}
