import XCTest
@testable import KVObserver



class KVObserverTests: XCTestCase {
	
	func testSimpleDirectObservation() {
		let kvObserver = KVObserver()
		let observedObject = ObservedObject()
		
		var enteredObservedBlock = false
		let observingId = kvObserver.observe(object: observedObject, keyPath: #keyPath(ObservedObject.observableProperty), kvoOptions: [], dispatchType: .direct){ _ in
			enteredObservedBlock = true
		}
		
		XCTAssertFalse(enteredObservedBlock)
		observedObject.observableProperty += 1
		XCTAssertTrue(enteredObservedBlock)
		
		enteredObservedBlock = false
		kvObserver.stopObserving(id: observingId)
		observedObject.observableProperty += 1
		XCTAssertFalse(enteredObservedBlock)
	}
	
	
	/* Fill this array with all the tests to have Linux testing compatibility. */
	static var allTests = [
		("testSimpleDirectObservation", testSimpleDirectObservation),
	]
	
}
