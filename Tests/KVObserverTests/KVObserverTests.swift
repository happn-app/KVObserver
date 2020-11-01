/*
Copyright 2019 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import CoreData
import XCTest
@testable import KVObserver



class KVObserverTests: XCTestCase {
	
	func testSimpleDirectObservation() {
		let kvObserver = KVObserver()
		let observedObject = ObservedObject()
		
		var enteredObservedBlock = false
		let observingId = kvObserver.observe(object: observedObject, keyPath: #keyPath(ObservedObject.observableProperty), kvoOptions: [], dispatchType: .direct, handler: { _ in
			enteredObservedBlock = true
		})
		
		XCTAssertFalse(enteredObservedBlock)
		observedObject.observableProperty += 1
		XCTAssertTrue(enteredObservedBlock)
		
		enteredObservedBlock = false
		kvObserver.stopObserving(id: observingId)
		observedObject.observableProperty += 1
		XCTAssertFalse(enteredObservedBlock)
	}
	
	func testObservedObjectDealloc() {
		/* We check the process don’t crash, mostly. Also check the logs of the
		 * test, verify the object is actually dealloc’d, etc.
		 * Note: We could probably check more things automatically, but then again
		 *       the moan point of the test was to check there are no crashes. */
		autoreleasepool{
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
		autoreleasepool{
			_ = NSEntityDescription.insertNewObject(forEntityName: "AutoObservedNSManagedObject", into: context)
		}
	}
	
}
