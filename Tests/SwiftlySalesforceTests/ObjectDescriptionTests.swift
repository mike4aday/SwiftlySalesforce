import XCTest
@testable import SwiftlySalesforce

class ObjectDescriptionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThatItInitsAccountObjectDescrxiption() {
        
        // Given
        let data = Mocker.accountObjectDescription.data(using: .utf8)!
        
        // When
        let desc = try! Mocker.jsonDecoder.decode(ObjectDescription.self, from: data)
        
        // Then
        var fields = [String: FieldDescription]()
        for (name, fieldMetadata) in zip(desc.fields!.map({ $0.name }), desc.fields!) {
            fields[name] = fieldMetadata
        }
        let accountTypeField = fields["Type"]!
        XCTAssertTrue(desc.isCreateable)
        XCTAssertFalse(desc.isCustom)
        XCTAssertFalse(desc.isCustomSetting)
        XCTAssertTrue(desc.isDeletable)
        XCTAssertTrue(desc.isFeedEnabled)
        XCTAssertTrue(desc.isQueryable)
        XCTAssertTrue(desc.isSearchable)
        XCTAssertTrue(desc.isTriggerable)
        XCTAssertTrue(desc.isUndeletable)
        XCTAssertTrue(desc.isUpdateable)
        XCTAssertEqual(desc.keyPrefix, "001")
        XCTAssertEqual(desc.keyPrefix, desc.idPrefix)
        XCTAssertEqual(desc.label, "Account")
        XCTAssertEqual(desc.name, "Account")
        XCTAssertEqual(desc.pluralLabel, "Accounts")
        XCTAssertEqual(desc.pluralLabel, desc.labelPlural)
        XCTAssertTrue(desc.fields!.count > 0)
        
        XCTAssertTrue(accountTypeField.isCreateable)
        XCTAssertFalse(accountTypeField.isCustom)
        XCTAssertNil(accountTypeField.defaultValue)
        XCTAssertNil(accountTypeField.helpText)
        XCTAssertEqual(accountTypeField.helpText, accountTypeField.inlineHelpText)
        XCTAssertFalse(accountTypeField.isEncrypted)
        XCTAssertTrue(accountTypeField.isSortable)
        XCTAssertEqual(accountTypeField.label, "Account Type")
        XCTAssertEqual(accountTypeField.length, 40)
        XCTAssertEqual(accountTypeField.name, "Type")
        XCTAssertTrue(accountTypeField.isNillable)
        XCTAssertTrue(accountTypeField.relatedTypes.count == 0)
        XCTAssertNil(accountTypeField.relationshipName)
        XCTAssertEqual(accountTypeField.type, "picklist")
        XCTAssertTrue(accountTypeField.isUpdateable)
        XCTAssertTrue(accountTypeField.picklistValues.count > 0)
    }
}
