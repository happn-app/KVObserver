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
import Foundation

import KVObserver



struct CoreDataStack {
	
	static func createStack() -> NSManagedObjectContext {
		let model = NSManagedObjectModel()
		
		let entity = NSEntityDescription()
		entity.name = "AutoObservedNSManagedObject"
		entity.managedObjectClassName = "AutoObservedNSManagedObject"
		
		let property = NSAttributeDescription()
		property.name = "observableProperty"
		property.attributeType = .integer16AttributeType
		property.defaultValue = 42
		
		entity.properties = [property]
		model.entities = [entity]
		
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
		
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = coordinator
		return context
	}
	
	private init() {}
	
}

/* In this class (an NSManagedObject subclass), we do KVO of self.
 * This a non-trivial thing to do, and MUST be done following very specific guidelines.
 * However, because we're in a unit test and I don't know how to otherwise, I did NOT follow all the rules to do the KVO.
 * DO **NOT** use this class as an example for KVO in an NSManagedObject! */
@objc(AutoObservedNSManagedObject)
class AutoObservedNSManagedObject : NSManagedObject {
	
	@NSManaged var observableProperty: Int16
	
	/* ***************************
	    MARK: - Core Data Overrides
	    *************************** */
	
	public override func awakeFromFetch() {
		/* This is also called when a fault is fulfilled (fulfilling a fault is a fetch).
		 * Always DO call super's implementation *first*.
		 *
		 * Context's changes processing is disabled in this method.
		 * However, this means inverse relationship are not set automatically when relationships are modified in this method. */
		super.awakeFromFetch()
		print("Awake from fetch for an AutoObservedNSManagedObject with observer \(Unmanaged.passUnretained(kvObserver).toOpaque())")
		
		if observingId == nil {
			observingId = kvObserver.observe(object: self, keyPath: #keyPath(AutoObservedNSManagedObject.observableProperty), kvoOptions: [.initial], dispatchType: .direct, handler: { [weak self] in self?.processKVOChange($0) })
		}
	}
	
	public override func awakeFromInsert() {
		/* Use primitive accessors to change properties values in this method.
		 * Always DO call super's implementation first. */
		super.awakeFromInsert()
		print("Awake from insert for an AutoObservedNSManagedObject with observer \(Unmanaged.passUnretained(kvObserver).toOpaque())")
		
		if observingId == nil {
			observingId = kvObserver.observe(object: self, keyPath: #keyPath(AutoObservedNSManagedObject.observableProperty), kvoOptions: [], dispatchType: .direct, handler: { [weak self] in self?.processKVOChange($0) })
		}
	}
	
	public override func willTurnIntoFault() {
		print("Will turn into fault for an AutoObservedNSManagedObject with observer \(Unmanaged.passUnretained(kvObserver).toOpaque())")
		/* DO unobserve here when observing an NSManagedObject correctly. */
//		if let id = observingId {kvObserver.stopObserving(id: id)}
//		observingId = nil
		
		super.willTurnIntoFault()
	}
	
	deinit {
		print("Deinit of an AutoObservedNSManagedObject with observer \(Unmanaged.passUnretained(kvObserver).toOpaque())")
		/* There is nothing to do in deinit when observing an NSManagedObject the correct way.
		 * However, for the test case we want to do, the observation deregistering must be done here
		 *  (it is where it happens in practice in the specific case we're interested in). */
		if let id = observingId {kvObserver.stopObserving(id: id)}
		observingId = nil
		
		/* This is wrong.
		 * On deinit the object is no longer in a context and Core complains (rightfully TBH).
		 * However, it does force a KVO notif, which is what we want. */
		observableProperty += 1
	}
	
	/* *******************
	 MARK - KVO-Handling
	 ******************* */
	
	private func processKVOChange(_ changes: [NSKeyValueChangeKey: Any]?) {
		/* With our wrong way of observing, the assertion below becomes false sometimes.
		 * In a real-world app, it can (should) be left uncommented. */
//		assert(faultingState == 0)
		print("KVO called in AutoObservedNSManagedObject")
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private let kvObserver = KVObserver()
	private var observingId: KVObserver.ObservingId?
	
}
