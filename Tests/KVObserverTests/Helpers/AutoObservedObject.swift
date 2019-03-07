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

import KVObserver



@objc(AutoObservedObject)
class AutoObservedObject : NSObject {
	
	@objc dynamic var observableProperty = 0
	
	override init() {
		super.init()
		
		observingId = kvObserver.observe(object: self, keyPath: #keyPath(AutoObservedObject.observableProperty), kvoOptions: [.initial], dispatchType: .direct, handler: { [weak self] _ in
			self?.handleChange()
		})
		observableProperty += 1
	}
	
	deinit {
		print("Deiniting of an AutoObservedObject")
		if let id = observingId {kvObserver.stopObserving(id: id)}
		observingId = nil
		
		observableProperty += 1
	}
	
	private func handleChange() {
		print("KVO changed in AutoObservedObject")
	}
	
	private let kvObserver = KVObserver()
	private var observingId: KVObserver.ObservingId?
	
}
