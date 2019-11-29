import XCTest
import Combine
@testable import SwiftlySalesforce

class Salesforce_QueryTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()
    
    struct Account: Codable {
        var Id: String
        var Name: String
        var CreatedDate: String
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Org must have some accounts
    func testThatItQueries() {
        
        // Given
        let sfdc = Util.salesforce
        let soql = "SELECT Id, Name, CreatedDate FROM Account"
        
        // When
        let pub = sfdc.query(soql: soql)
     
        // Then
        let exp = expectation(description: "Query account records")
        pub.sink(receiveCompletion: { (completion) in
            exp.fulfill()
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
        }, receiveValue: { queryResult in
            XCTAssertTrue(queryResult.records.count > 0)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testThatItQueriesNoRecords() {
        
        // Given
       let sfdc = Util.salesforce
       let soql = "SELECT Id, Name, CreatedDate FROM Account WHERE CreatedDate > NEXT_YEAR"
       
       // When
       let pub = sfdc.query(soql: soql)
    
       // Then
       let exp = expectation(description: "Query account records")
       pub.sink(receiveCompletion: { (completion) in
           switch completion {
           case let .failure(error):
               XCTFail("\(error)")
           case .finished:
               break
           }
           exp.fulfill()
       }, receiveValue: { queryResult in
           XCTAssertTrue(queryResult.records.count == 0)
       })
       .store(in: &subscriptions)
       waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testThatQueryFails() {
        
        // Given
       let sfdc = Util.salesforce
       let soql = "SELECT Id, Name, CreatedDate FROM NonExistentObject WHERE CreatedDate > NEXT_YEAR"
       
       // When
       let pub = sfdc.query(soql: soql)
    
       // Then
       let exp = expectation(description: "Query account records")
       pub.sink(receiveCompletion: { (completion) in
           switch completion {
           case .failure:
                // Error expected
                break
           case .finished:
                break
           }
           exp.fulfill()
       }, receiveValue: { queryResult in
           XCTFail("Query should have failed")
       })
       .store(in: &subscriptions)
       waitForExpectations(timeout: 60, handler: nil)
    }
    
    // Org must have at least 201 accounts
    func testThatQueryResultPaginates() {
        
        // Given
        let sfdc = Util.salesforce
        let soql = "SELECT Id, Name, CreatedDate FROM Account"
           
        // When
        let pub = sfdc.query(soql: soql, batchSize: 200)
        
        // Then
        let exp = expectation(description: "Query account records")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { queryResult in
            XCTAssertFalse(queryResult.isDone)
            XCTAssertNotNil(queryResult.nextRecordsPath)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    // Org must have some accounts
    func testThatItQueriesCodableModel() {
        
        // Given
        let sfdc = Util.salesforce
        let soql = "SELECT Id, Name, CreatedDate FROM Account"
        
        // When
        let pub: AnyPublisher<QueryResult<Account>, Error> = sfdc.query(soql: soql)
     
        // Then
        let exp = expectation(description: "Query account records")
        pub.sink(receiveCompletion: { (completion) in
            switch completion {
            case let .failure(error):
                XCTFail("\(error)")
            case .finished:
                break
            }
            exp.fulfill()
        }, receiveValue: { queryResult in
            XCTAssertTrue(queryResult.records.count > 0)
        })
        .store(in: &subscriptions)
        waitForExpectations(timeout: 60, handler: nil)
    }
}
