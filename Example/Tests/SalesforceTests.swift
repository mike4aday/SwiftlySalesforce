//
//  SalesforceTests.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

import XCTest
import PromiseKit
@testable import SwiftlySalesforce

class SalesforceTests: XCTestCase, MockData, LoginDelegate {
	
	var salesforce: Salesforce!
	
	override func setUp() {
		super.setUp()
		let config = readPropertyList(fileName: "OAuth2")!
		let consumerKey = config["ConsumerKey"] as! String
		let redirectURLWithAuth = URL(string: config["RedirectURLWithAuthData"] as! String)!
		salesforce = TestUtils.shared.createSalesforce(consumerKey: consumerKey, enrichedRedirectURL: redirectURLWithAuth)
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testThatItGetsIdentity() {
		
		let exp = expectation(description: "Identity")
		
		salesforce.identity().then {
			identity -> () in
			XCTAssertEqual(identity.userID, self.salesforce.connectedApp.authData!.userID)
			XCTAssertEqual(identity.orgID, self.salesforce.connectedApp.authData!.orgID)
			exp.fulfill()
		}.catch {
			error in
			XCTFail(String(describing: error))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItGetsLimits() {
		
		let exp = expectation(description: "limits")
		
		salesforce.limits()
			.then {
				limits -> () in
				XCTAssertTrue(limits.count > 20) // ~23 as of Winter '17
				exp.fulfill()
			}.catch {
				error in
				XCTFail(String(describing: error))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItQueriesNoRecords() {
		
		let soql = "SELECT Id FROM Account WHERE CreatedDate > NEXT_WEEK"
		let exp = expectation(description: "Query")
		
		salesforce.query(soql: soql)
			.then {
				queryResult -> () in
				XCTAssertEqual(queryResult.records.count, 0)
				XCTAssertEqual(queryResult.totalSize, 0)
				XCTAssertTrue(queryResult.isDone)
				XCTAssertNil(queryResult.nextRecordsPath)
				exp.fulfill()
			}.catch {
				error in
				XCTFail(String(describing: error))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItRunsMultipleQueries() {
		
		let account = [ "Name": "Bit Player, Inc.", "BillingPostalCode": "02214"]
		let contact = ["FirstName": "Jason", "LastName": "Johnson"]
		let exp = expectation(description: "Run multiple queries")
		
		first {
			salesforce.insert(type: "Account", fields: account)
		}.then {
			(accountID: String) -> Promise<(String, String)> in
			return self.salesforce.insert(type: "Contact", fields: contact).then { (accountID, $0) }
		}.then {
			(accountID, contactID) -> Promise<[QueryResult<Record>]> in
			let q1 = "SELECT Id FROM Account WHERE Id = '\(accountID)'"
			let q2 = "SELECT Id FROM Contact WHERE Id = '\(contactID)'"
			return self.salesforce.query(soql: [q1, q2])
		}.then {
			(queryResults: [QueryResult]) -> Void in
			XCTAssert(queryResults.count == 2)
			XCTAssert(queryResults[0].totalSize == 1)
			XCTAssert(queryResults[1].totalSize == 1)
			exp.fulfill()
		}.catch {
			XCTFail($0.localizedDescription)
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItRetrieves() {
		
		// Note: At least 1 Account record must be in the org
		
		let soql = "SELECT Id FROM Account ORDER BY Id LIMIT 1"
		let exp = expectation(description: "Retrieve Account record")
		
		salesforce.query(soql: soql)
			.then {
				(queryResult) -> Promise<Record> in
				XCTAssertTrue(queryResult.records.count > 0)
				return self.salesforce.retrieve(type: "Account", id: queryResult.records[0].id!)
			}.then {
				// Then
				(record: Record) -> () in
				XCTAssertEqual("Account", record.type)
				exp.fulfill()
			}.catch {
				XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItQueriesAndDecodes() {
		
		struct Account: Decodable {
			var id: String
			var name: String
			var lastModifiedDate: Date
			enum CodingKeys: String, CodingKey {
				case id = "Id"
				case name = "Name"
				case lastModifiedDate = "LastModifiedDate"
			}
		}
		
		struct Contact: Decodable {
			var id: String
			var firstName: String
			var lastName: String
			var createdDate: Date
			var account: Account?
			enum CodingKeys: String, CodingKey {
				case id = "Id"
				case firstName = "FirstName"
				case lastName = "LastName"
				case createdDate = "CreatedDate"
				case account = "Account"
			}
		}
		
		let exp = expectation(description: "Query and decode")
		let soql = "SELECT Id, FIRSTNAME, LastName, CreatedDate, Account.Id, Account.Name, Account.LastModifiedDate FROM Contact"
		
		salesforce.query(soql: soql).then {
			(queryResult: QueryResult<Contact>) -> () in
			for contact in queryResult.records {
				XCTAssertTrue(contact.id.hasPrefix("003"))
				if let account = contact.account {
					XCTAssertTrue(account.id.hasPrefix("001"))
				}
			}
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItPerformsMultipleQueries() {
		
		let exp = expectation(description: "Multiple queries")
		
		// Insert multiple records
		let accountFields = ["Name": "Corp1, Inc.", "Website": "http://www.mycorp1.com"]
		let contactFields = ["FirstName": "Joseph", "LastName": "Jones", "Email": "jj@mycorp1.com", "Phone": "+1 212-555-1212"]
		fulfill(salesforce.insert(type: "Account", fields: accountFields), salesforce.insert(type: "Contact", fields: contactFields)).then {
			(accountID: String, contactID: String) -> Promise<Array<QueryResult<Record>>> in
			let accountQuery = "SELECT Id, Name, Website FROM Account WHERE Id = '\(accountID)'"
			let contactQuery = "SELECT Id, FirstName, LastName, Email, LastModifiedDate FROM Contact WHERE Id = '\(contactID)'"
			return self.salesforce.query(soql: [accountQuery, contactQuery])
		}.then {
			(queryResults: [QueryResult<Record>]) -> () in
			
			XCTAssert(queryResults.count == 2)
			
			let account = queryResults[0].records[0]
			XCTAssertEqual(account["Name"], "Corp1, Inc.")
			XCTAssertEqual(account["Website"], URL(string: "http://www.mycorp1.com")!)
			
			let contact = queryResults[1].records[0]
			XCTAssertEqual("Jones", contact["LastName"])
			XCTAssertEqual("Joseph", contact["FirstName"])
			XCTAssertEqual("jj@mycorp1.com", contact["Email"])
			XCTAssertNotNil(contact.date(forField: "LastModifiedDate"))
			
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItUpdatesForFields() {
		
		let exp = expectation(description: "Update with fields dictionary")
		
		salesforce.insert(type: "Account", fields: ["Name": "Important Corp., Inc.", "Website": "http://importantcorp.com", "Sic": "A123"]).then {
			(id: String) -> Promise<Record> in
			return self.salesforce.retrieve(type: "Account", id: id)
		}.then {
			(account: Record) -> Record in
			XCTAssertEqual(account.string(forField: "Name"), "Important Corp., Inc.")
			XCTAssertEqual(account.url(forField: "Website"), URL(string: "http://importantcorp.com"))
			XCTAssertNil(account.address(forField: "BillingAddress"))
			XCTAssertEqual(account.string(forField: "Sic"), "A123")
			return account
		}.then {
			(account: Record) -> Promise<String> in
			let fields = [
				"Name": "My New Corp.",
				"Website": nil,
				"BillingStreet": "123 Main St.",
				"BillingCity": "St. Paul",
				"Sic": nil
			]
			return self.salesforce.update(type: account.type, id: account.id!, fields: fields).then { account.id! }
		}.then {
			(id: String) -> Promise<Record> in
			return self.salesforce.retrieve(type: "Account", id: id)
		}.then {
			(account: Record) -> () in
			XCTAssertEqual(account.string(forField: "Name"), "My New Corp.")
			XCTAssertNil(account.url(forField: "Website"))
			XCTAssertEqual(account.string(forField: "BillingStreet"), "123 Main St.")
			XCTAssertEqual(account.string(forField: "BillingCity"), "St. Paul")
			XCTAssertNil(account.string(forField: "Sic"))
		}.catch {
			XCTFail(String(describing: $0))
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItUpdatesForRecord() {
		
		let exp = expectation(description: "Update Salesforce using Record instance")
		let fields: [String: Encodable?] = ["Name": "Important Corp., Inc.", "Website": "http://importantcorp.com", "Sic": "A123", "BillingPostalCode": nil, "NumberOfEmployees": 10]
		
		salesforce.insert(record: Record(type: "Account", fields: fields)).then {
			(id: String) -> Promise<Record> in
			return self.salesforce.retrieve(type: "Account", id: id)
		}.then {
			(returnValue: Record) -> Promise<String> in
			
			var account = returnValue // returnValue is 'let' constant; we need 'var'
			
			XCTAssertNotNil(account.id)
			XCTAssertEqual(account.type, "Account")
			XCTAssertEqual(account.string(forField: "Name"), "Important Corp., Inc.")
			XCTAssertEqual(account.url(forField: "Website"), URL(string: "http://importantcorp.com"))
			XCTAssertNil(account.address(forField: "BillingAddress"))
			XCTAssertEqual(account.string(forField: "Sic"), "A123")
			XCTAssertEqual(account.int(forField: "NumberOfEmployees"), 10)

			account.setValue("My New Corp.", forField: "Name")
			account.setValue(nil, forField: "Website")
			account.setValue("123 Main St.", forField: "BillingStreet")
			account.setValue("St. Paul", forField: "BillingCity")
			account.setValue(nil, forField: "Sic")
			
			XCTAssertNotNil(account.id)
			XCTAssertEqual(account.type, "Account")
			XCTAssertEqual(account.string(forField: "Name"), "My New Corp.")
			XCTAssertNil(account.url(forField: "Website"))
			XCTAssertEqual(account.string(forField: "BillingStreet"), "123 Main St.")
			XCTAssertNil(account.string(forField: "Sic"))

			return self.salesforce.update(record: account).then {
				account.id!
			}
		}.then {
			(id: String) -> Promise<Record> in
			// Retrieve the account from Salesforce again
			return self.salesforce.retrieve(type: "Account", id: id)
		}.then {
			(account: Record) -> () in
			XCTAssertEqual(account.type, "Account")
			XCTAssertEqual(account.string(forField: "Name"), "My New Corp.")
			XCTAssertNil(account.url(forField: "Website"))
			XCTAssertEqual(account.string(forField: "BillingStreet"), "123 Main St.")
			XCTAssertEqual(account.string(forField: "BillingCity"), "St. Paul")
			XCTAssertNil(account.string(forField: "Sic"))
		}.catch {
			XCTFail(String(describing: $0))
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItUpdatesForCodable() {
		
		let exp = expectation(description: "Update Salesforce using custom Codable instance")
		let df = DateFormatter()
		df.dateFormat = "YYYY-MM-DD"
		
		first {
			return salesforce.insert(type: "Contact", record: MyContact(firstName: "John", lastName: "Doe", birthdate: nil))
		}.then {
			return self.salesforce.retrieve(type: "Contact", id: $0)
		}.then {
			(retrieved: MyContact) -> Promise<String> in
			
			var contact = retrieved // Make it writeable
			
			XCTAssertNotNil(contact.id)
			XCTAssertEqual("John", contact.firstName)
			XCTAssertEqual("Doe", contact.lastName)
			XCTAssertNil(contact.birthdate)
			
			contact.birthdate = df.date(from: "1975-05-02")
			contact.firstName = "Fred"
			return self.salesforce.update(type: "Contact", id: contact.id!, record: contact).then { contact.id! }
		}.then {
			(id: String) -> Promise<MyContact> in
			// Retrieve again
			return self.salesforce.retrieve(type: "Contact", id: id)
		}.then {
			(contact: MyContact) -> Void in
			
			// Confirm updates
			XCTAssertEqual("Fred", contact.firstName)
			XCTAssertEqual("Doe", contact.lastName)
			XCTAssertEqual(contact.birthdate, df.date(from: "1975-05-02"))
		}.catch {
			error in
			debugPrint("\(error)")
			XCTFail()
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)
	}
	
	func testThatItRetrievesAndDecodes() {
		
		struct MyAccount: Decodable {
			var Id: String
			var Name: String
			var LastModifiedDate: String
			var Website: URL?
		}
		
		let exp = expectation(description: "Retrieve and decode")

		salesforce.insert(type: "Account", fields: ["Name": "Important Corp., Inc.", "Website": "http://importantcorp.com"]).then {
			(id: String) -> Promise<MyAccount> in
			return self.salesforce.retrieve(type: "Account", id: id)
		}.then {
			(account: MyAccount) -> String in
			XCTAssertEqual(account.Name, "Important Corp., Inc.")
			XCTAssertEqual(account.Website, URL(string: "http://importantcorp.com"))
			XCTAssertNotNil(account.LastModifiedDate)
			return account.Id
		}.then {
			(id: String) -> Promise<String> in
			return self.salesforce.update(type: "Account", id: id, fields: ["Name": "My New Corp.", "Website": nil]).then { id }
		}.then {
			(id: String) -> Promise<MyAccount> in
			return self.salesforce.retrieve(type: "Account", id: id)
		}.then {
			(account: MyAccount) -> () in
			XCTAssertEqual(account.Name, "My New Corp.")
			XCTAssertNil(account.Website)
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItRetrievesViaCustomResource() {
		
		let exp = expectation(description: "Test custom resource for simple retrieval")
		
		first {
			salesforce.insert(type: "Account", fields: ["Name": "My Company", "Website": URL(string: "http://www.mycompany.com")!])
		}.then {
			(id: String) -> Promise<Data> in
			let path = "/services/data/v40.0/sobjects/account/\(id)"
			return self.salesforce.custom(method: .get, baseURL: nil, path: path, parameters: nil, headers: nil)
		}.then {
			(data: Data) -> () in
			let decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateTimeFormatter)
			let record = try decoder.decode(Record.self, from: data)
			XCTAssertEqual("My Company", record.string(forField: "Name"))
			XCTAssertEqual("http://www.mycompany.com", record.url(forField: "Website")!.absoluteString)
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItFailsToRetrieve() {
		
		let type = "Account"
		let id = "001xxxxxxxxxxxxxxx"
		let exp = expectation(description: "Retrieve nonexistent \(type) record")
		
		first {
			salesforce.retrieve(type: type, id: id)
			}.then {
				// Then
				(result: QueryResult<Record>) -> () in
				XCTFail()
			}.catch {
				error in
				exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItInsertsAccountForFields() {
	
		let fields: [String: Encodable?] = [
			"Name" : "Megacorp, Inc.",
			"BillingPostalCode": "12345",
			"Website": URL(string: "http://megacorp.com")!,
			"BillingStreet": nil
		]
		let exp = expectation(description: "Insert Account record")
		
		first {
			salesforce.insert(type: "Account", fields: fields)
		}.then {
			// Then
			id -> String in
			XCTAssertTrue(id.hasPrefix("001"))
			XCTAssertTrue(id.characters.count >= 15)
			return id
		}.then {
			// Delete record that was just inserted
			return self.salesforce.delete(type: "Account", id: $0)
		}.then {
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItInsertsAccountForRecord() {
		
		var record = Record(type: "Account")
		record.setValue("Worldwide Shirts, Inc.", forField: "Name")
		record.setValue("(212) 555-1212", forField: "Phone")
		record.setValue(5, forField: "NumberOfEmployees")
		record.setValue(nil, forField: "AnnualRevenue")
		record.setValue(Date(), forField: "playgroundorg__SLAExpirationDate__c")
		let exp = expectation(description: "Insert Account record")
		
		first {
			salesforce.insert(record: record)
		}.then {
			// Then
			id -> String in
			XCTAssertTrue(id.hasPrefix("001"))
			XCTAssertTrue(id.characters.count >= 15)
			return id
		}.then {
			// Delete record that was just inserted
			return self.salesforce.delete(type: "Account", id: $0)
		}.catch {
			XCTFail(String(describing: $0))
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItInsertsTask() {
		
		let fields: [String: Encodable?] = [
			"Subject" : "A Superhuman Task",
			"IsReminderSet": true,
			"ReminderDateTime": Date(timeIntervalSinceNow: 125000),
			"ActivityDate": nil
		]
		let exp = expectation(description: "Insert Task record")
		
		first {
			salesforce.insert(type: "Task", fields: fields)
			}.then {
				// Then
				id -> String in
				XCTAssertTrue(id.hasPrefix("00T"))
				XCTAssertTrue(id.characters.count >= 15)
				return id
			}.then {
				// Delete record that was just inserted
				return self.salesforce.delete(type: "Task", id: $0)
			}.then {
				id in
				exp.fulfill()
			}.catch {
				XCTFail(String(describing: $0))
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDeletesForID() {
		
		let fields = [ "Name" : "Worldwide Stuff, Inc.", "BillingPostalCode": "44554"]
		let exp = expectation(description: "Delete Account record by ID")
		
		first {
			// Insert it
			salesforce.insert(type: "Account", fields: fields)
		}.then {
			// Delete it
			(id: String) -> Promise<String> in
			return self.salesforce.delete(type: "Account", id: id).then { id }
		}.then {
			// Try to query it
			(id: String) -> Promise<QueryResult<Record>> in
			return self.salesforce.query(soql: "SELECT Id FROM Account WHERE Id = '\(id)'")
		}.then {
			// Then shoudn't be found
			(queryResult: QueryResult) -> Void in
			XCTAssert(queryResult.totalSize == 0)
		}.catch {
			XCTFail("\($0)")
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDeletesForRecord() {
		
		let fields = [ "Name" : "Worldwide Stuff, Inc.", "BillingPostalCode": "44554"]
		var record = Record(type: "Account", fields: fields)
		let exp = expectation(description: "Delete Account record by Record instance")
		
		first {
			// Insert it
			salesforce.insert(record: record)
		}.then {
			// Delete it
			(id: String) -> Promise<String> in
			record.id = id
			return self.salesforce.delete(record: record).then { id }
		}.then {
			// Try to query it
			(id: String) -> Promise<QueryResult<Record>> in
			return self.salesforce.query(soql: "SELECT Id FROM Account WHERE Id = '\(id)'")
		}.then {
			// Then shoudn't be found
			(queryResult: QueryResult) -> Void in
			XCTAssert(queryResult.totalSize == 0)
		}.catch {
			XCTFail("\($0)")
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDescribes() {
		
		let type = "Account"
		let exp = expectation(description: "Describe Account")
		
		salesforce.describe(type: type).then {
			(desc: ObjectMetadata) -> () in
			let fields = Dictionary(items: desc.fields!) { $0.name }
			XCTAssertEqual(desc.name, "Account")
			XCTAssertTrue(fields.count > 0)
			XCTAssertNotNil(fields["Type"])
			XCTAssertEqual(fields["Type"]!.type, "picklist")
			XCTAssertEqual(fields["MasterRecordId"]!.referenceTo![0], "Account")
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDescribesAll() {
		
		let exp = expectation(description: "Describe All (Describe Global)")
		
		salesforce.describeAll()
			.then {
				(result: [ObjectMetadata]) -> () in
				let objDescs = Dictionary(items: result) { $0.name }
				guard let acct = objDescs["Account"], acct.name == "Account", acct.keyPrefix == "001",
					let contact = objDescs["Contact"], contact.name == "Contact"
					else {
						XCTFail()
						return
				}
				exp.fulfill()
			}.catch {
				XCTFail(String(describing: $0))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItFailsToDescribe() {

		let type = "A Nonexistent Object"
		let exp = expectation(description: "Describe nonexistent object")
		
		salesforce.describe(type: type)
			.then {
				// Then
				desc -> () in
				XCTFail()
			}.catch {
				error in
				exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItDescribesMultipleObjects() {
		
		let types = ["Event", "Account", "Contact", "Lead", "Task"]
		let exp = expectation(description: "Describe multiple objects")
		
		first {
			salesforce.describe(types: types)
			}.then {
				result -> () in
				XCTAssertEqual(result.count, types.count)
				XCTAssertEqual(result.map { $0.name }, types)
				exp.fulfill()
			}.catch {
				error in
				XCTFail(error.localizedDescription)
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItFailsToDescribesMultipleObjects() {
		
		let types = ["Event", "XXXXXXXXX", "Contact", "Lead", "Task"]
		let exp = expectation(description: "Describe multiple objects")
		
		first {
			salesforce.describe(types: types)
		}.then {
			result -> () in
			XCTFail()
		}.catch {
			error in
			// Ignore
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItFetchesImage() {
		
		let exp = expectation(description: "Fetch photo for user")
		
		first {
			salesforce.identity()
		}.then {
			// Retrieve photo
			(identity: Identity) -> Promise<UIImage> in
			return self.salesforce.fetchImage(url: identity.photoURL!)
		}.then {
			(image: UIImage) -> Void in
			XCTAssert(image.size.width > 0)
			XCTAssert(image.size.height > 0)
		}.catch {
			error in
			debugPrint(error)
			XCTFail()
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItRetrievesOrg() {
		
		let exp = expectation(description: "Retrieve org")
		
		first {
			return salesforce.org()
		}.then {
			(org) -> () in
			XCTAssertTrue(org.createdDate < Date())
		}.catch {
			XCTFail("\($0)")
		}.always {
			exp.fulfill()
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItGetsAccountFromApexResource() {
		
		let namespace = "playgroundorg"
		let acctID = "001i000000JEK7m" // This must exist already
		let exp = expectation(description: "Retrieve Account record via custom Apex REST method")
		
		salesforce.apex(method: .get, path: "/\(namespace)/Account/\(acctID)", parameters: nil, body: nil, contentType: nil, headers: nil).then {
			(data) -> () in
			let decoder = JSONDecoder(dateFormatter: DateFormatter.salesforceDateTimeFormatter)
			let record = try decoder.decode(Record.self, from: data)
			XCTAssertTrue(record.type == "Account")
			XCTAssertTrue(record.id!.starts(with: acctID))
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testThatItPostsAccountToApexResource() {
		
		let namespace = "playgroundorg"
		let json = """
		{
			"name" : "Wingo Ducks",
			"phone" : "707-555-1234",
			"website" : "www.wingo.ca.us"
		}
		"""
		let body = json.data(using: .utf8)
		let exp = expectation(description: "Retrieve Account record via custom Apex REST method")
		
		salesforce.apex(method: .post, path: "/\(namespace)/Account/)", parameters: nil, body: body, contentType: nil, headers: nil).then {
			(data) -> () in
			let _ = String(data: data, encoding: .utf8)
			exp.fulfill()
		}.catch {
			XCTFail(String(describing: $0))
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
}

// MARK: -
struct MyContact {
	
	var id: String?
	var firstName: String?
	var lastName: String
	var birthdate: Date?
	
	init(id: String? = nil, firstName: String? = nil, lastName: String, birthdate: Date? = nil) {
		self.id = id
		self.firstName = firstName
		self.lastName = lastName
		self.birthdate = birthdate
	}
}

extension MyContact: Encodable {
	
	enum EncodingKeys: String, CodingKey {
		case firstName = "FirstName"
		case lastName = "LastName"
		case birthdate = "Birthdate"
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: EncodingKeys.self)
		try container.encode(firstName, forKey: .firstName)
		try container.encode(lastName, forKey: .lastName)
		try container.encode(birthdate, forKey: .birthdate)
	}
}

extension MyContact: Decodable {
	
	enum DecodingKeys: String, CodingKey {
		case id = "Id"
		case firstName = "FirstName"
		case lastName = "LastName"
		case birthdate = "Birthdate"
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: DecodingKeys.self)
		self.id = try values.decode(String.self, forKey: .id)
		self.firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
		self.lastName = try values.decode(String.self, forKey: .lastName)
		
		// Birthdate JSON has different format than other dates (date, not date/time)
		let bdayString = try values.decodeIfPresent(String.self, forKey: .birthdate)
		if let s = bdayString {
			let df = DateFormatter()
			df.dateFormat = "YYYY-MM-DD"
			self.birthdate = df.date(from: s)
		}
	}
}
