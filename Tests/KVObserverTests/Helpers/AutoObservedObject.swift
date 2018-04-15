/*
 * AutoObservedObject.swift
 * KVObserver
 *
 * Created by François Lamboley on 14/04/2018.
 * Copyright © 2018 happn. All rights reserved.
 */

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
