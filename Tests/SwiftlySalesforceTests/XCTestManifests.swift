import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftlySalesforce9Tests.allTests),
    ]
}
#endif
