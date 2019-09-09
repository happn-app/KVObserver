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

import Foundation



class ObservationInfos: Hashable {
	
	let keyPath: String
	let observerObject: NSObject
	let kvoOptions: NSKeyValueObservingOptions
	let dispatchType: KVObserver.DispatchType
	
	init(observerObject: NSObject, keyPath: String, kvoOptions: NSKeyValueObservingOptions, dispatchType: KVObserver.DispatchType) {
		self.observerObject = observerObject
		self.keyPath = keyPath
		self.kvoOptions = kvoOptions
		self.dispatchType = dispatchType
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(keyPath)
		hasher.combine(observerObject.hashValue)
	}
	
	static func == (lhs: ObservationInfos, rhs: ObservationInfos) -> Bool {
		/* We can do a comparison between the two observerObject directly because
		 * they are instance of NSObject and implementation of Equatable in
		 * NSObject guarantees us that objects are really different. Indeed they
		 * are compared at pointer level */
		return lhs.keyPath == rhs.keyPath && lhs.observerObject == rhs.observerObject
	}
	
}


protocol Observing: class {
	var kvObserver: KVObserver {get}
	var observingInfos: Set<ObservationInfos> {get}
	var observingIds: Set<KVObserver.ObservingId> {get set}
	
	func addObservers()
	func stopObserving()
	func processChanges(_ changes: [NSKeyValueChangeKey : Any]?)
}


extension Observing {
	func addObservers() {
		if observingIds.isEmpty {
			for observingInfos in observingInfos {
				let observingID = kvObserver.observe(object: observingInfos.observerObject, keyPath: observingInfos.keyPath, kvoOptions: observingInfos.kvoOptions, dispatchType: observingInfos.dispatchType, handler: { changes in self.processChanges(changes) })
				observingIds.insert(observingID)
			}
		}
	}
	
	func stopObserving() {
		kvObserver.stopObserving(ids: observingIds)
		observingIds.removeAll()
	}
	
}
