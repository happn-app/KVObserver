import XCTest

extension KVObserverTests {
    static let __allTests = [
        ("testCoreDataObservedObjectDealloc", testCoreDataObservedObjectDealloc),
        ("testObservedObjectDealloc", testObservedObjectDealloc),
        ("testSimpleDirectObservation", testSimpleDirectObservation),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KVObserverTests.__allTests),
    ]
}
#endif
