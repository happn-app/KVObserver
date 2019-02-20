import CoreData
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
	
	func testObservedObjectDealloc() {
		_ = autoreleasepool{
			AutoObservedObject().observableProperty += 1
		}
	}
	
	func testCoreDataObservedObjectDealloc() {
		/* So. This is a tough one.
		 *
		 * Sometimes, Core Data calls deinit on an NSManagedObject instance
		 * _before_ calling `willTurnIntoFault`. The method is however correctly
		 * called while the object is being deallocated.
		 * We tear-down KVO (by calling `stopObserving` on the KVObserver) in the
		 * `willTurnIntoFault` method. In the case where this method is called
		 * while the object is being deallocated, all of its weak references have
		 * been nil-ed! Which means the `stopObserving` method actually used to do
		 * nothing in this case (with the first version of KVObserver).
		 * This should not have been a problem, because all KVO notification
		 * should be stopped while the object is being deallocated (not 100% sure,
		 * but it is the observed behaviour in the `testObservedObjectDealloc`
		 * test though). Indeed, Core Data being so nice, it still sends KVO
		 * notification when the object turns into a fault (part of the specs to
		 * be fair, IIRC).
		 * To solve the problem, we store Core Data objects as pointers instead of
		 * weak references in the KVObserver context in order for the KVO tear-
		 * down to actually work. */
		let context = CoreDataStack.createStack()
		_ = autoreleasepool{
			NSEntityDescription.insertNewObject(forEntityName: "AutoObservedNSManagedObject", into: context)
		}
	}
	
}
