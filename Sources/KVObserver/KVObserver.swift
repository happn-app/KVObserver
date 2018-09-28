/*
 * KVObserver.swift
 * happn
 *
 * Created by François Lamboley on 5/1/17.
 * Copyright © 2017 happn. All rights reserved.
 */

import CoreData
import Foundation



public final class KVObserver : NSObject {
	
	public typealias ObservingId = Int
	
	public enum DispatchType {
		
		case direct
		
		case async(DispatchQueue)
		/** `= .async(.main)` */
		case asyncOnMainQueue
		/** Async dispatch, except for initial KVO call (if .initial option is
		set) which is sent directly with no dispatch. */
		case asyncDirectInitial(DispatchQueue)
		/** `= .asyncDirectInitial(.main)`. Recommended value to use. */
		case asyncOnMainQueueDirectInitial
		/** If on main **thread** at callback time, will call the handler directly
		(synchronously). If not, the handler will be dispatched asynchronously on
		the main queue. */
		case directOrAsyncOnMainQueue
		/** Dangerous; sends event synchronously on the given queue. However, no
		check are done to check whether already on the queue! (If you already are,
		a sync dispatch dead-locks (or crashes depending on the compilation
		options/iOS versions)). */
		case unsafeSync(DispatchQueue)
		
		/* For Core Data */
		
		/** Async dispatch on given context. */
		case coreDataAsync(NSManagedObjectContext)
		/** Sync dispatch on given context. Note: If you're observing a Core Data
		object and you want synchronous dispatch, there’s no need to use this mode
		as a simple `.direct` dispatch will be enough (and you’ll be guaranteed to
		be on the context as the properties of the object can only change on said
		context). */
		case coreDataSync(NSManagedObjectContext)
		/** Async dispatch on given context, except for initial KVO call (if
		.initial option is set) which is sent directly with no dispatch. */
		case coreDataAsyncDirectInitial(NSManagedObjectContext)
		/** Sync dispatch on given context, except for initial KVO call (if
		.initial option is set) which is sent directly with no dispatch. */
		case coreDataSyncDirectInitial(NSManagedObjectContext)
		
		case coreDataInferredAsync
		case coreDataInferredSync
		case coreDataInferredAsyncDirectInitial
		case coreDataInferredSyncDirectInitial
		
		var isOnCoreDataInferredContext: Bool {
			switch self {
			case .coreDataInferredSync, .coreDataInferredAsync, .coreDataInferredSyncDirectInitial, .coreDataInferredAsyncDirectInitial: return true
			default:                                                                                                                     return false
			}
		}
		
	}
	
	deinit {
		stopObservingEverything()
	}
	
	@discardableResult
	public func observe(object: NSObject, keyPath: String, kvoOptions: NSKeyValueObservingOptions, dispatchType: DispatchType, keepPointerToObjectInsteadOfWeakReference: Bool? = nil, handler: @escaping (_ change: [NSKeyValueChangeKey: Any]?) -> Void) -> ObservingId {
		return observe(object: object, keyPath: keyPath, kvoOptions: kvoOptions, dispatchType: dispatchType, skipReRegistration: false, keepPointerToObjectInsteadOfWeakReference: keepPointerToObjectInsteadOfWeakReference, handler: handler)!
	}
	
	/** Will observe the given key path of the given object. When there is a
	modification, the handler will be called. The calling of the handler will be
	dispatched depending on the `dispatchType` parameter. See the doc of the
	DispatchType type for more information.
	
	It is recommended to use the `.asyncOnMainQueueDirectInitial` dispatch type,
	or a fully asynchronous dispatch type. Synchronous dispatches are usually a
	bad idea.
	
	Skip re-registration will not register for observation iff the given object/
	key-path couple has already been registered for observation.
	
	The observed object is stored as a weak reference by default, except for
	NSManagedObject instances, which are stored as an unmanaged pointer. You can
	change this behaviour with keepPointerToObjectInsteadOfWeakReference (but you
	really should not). See the `testCoreDataObservedObjectDealloc` test for more
	information.
	
	- Important: Not thread-safe (or maybe it is, but untested).
	
	- Returns: An observing ID that can used to stop the observation, nil if skip
	re-registration is true and registration was already setup for the given
	object/key-path couple. */
	@discardableResult
	public func observe(object: NSObject, keyPath: String, kvoOptions: NSKeyValueObservingOptions, dispatchType: DispatchType, skipReRegistration: Bool = false, keepPointerToObjectInsteadOfWeakReference: Bool? = nil, handler: @escaping (_ change: [NSKeyValueChangeKey: Any]?) -> Void) -> ObservingId? {
		let context = KVOContext(
			object: object, storeAsPointer: keepPointerToObjectInsteadOfWeakReference ?? (object is NSManagedObject ? true : false),
			keyPath: keyPath, dispatchType: dispatchType, willCallInitial: kvoOptions.contains(.initial), handler: handler
		)
		guard !skipReRegistration || !observingIdToContext.values.contains(context) else {return nil}
		
		object.addObserver(self, forKeyPath: keyPath, options: kvoOptions, context: Unmanaged.passUnretained(context).toOpaque())
		
		currentObservingId += 1
		observingIdToContext[currentObservingId] = context
		return currentObservingId
	}
	
	/** Crashes if trying to stop observing with an id not corresponding to an
	active observing.
	
	- Important: Not thread-safe (or maybe it is, but untested). */
	public func stopObserving(id: ObservingId) {
		let context = observingIdToContext[id]!
		
		context.observedObject?.removeObserver(self, forKeyPath: context.observedKeyPath, context: Unmanaged.passUnretained(context).toOpaque())
		observingIdToContext.removeValue(forKey: id)
	}
	
	/** Crashes if any id in the array is not an active observing id (has already
	been stopped, or has never been returned as an observing id).
	
	- Important: Not thread-safe (or maybe it is, but untested). */
	public func stopObserving(ids: Set<ObservingId>) {
		for id in ids {stopObserving(id: id)}
	}
	
	public func stopObservingEverything() {
		for (_, context) in observingIdToContext {context.observedObject?.removeObserver(self, forKeyPath: context.observedKeyPath, context: Unmanaged.passUnretained(context).toOpaque())}
		observingIdToContext.removeAll()
	}
	
	/* ********************
	   MARK: - KVO-Handling
	   ******************** */
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		/* We assume self we never be used for observing anything that we did not
		 * register ourselves. */
		Unmanaged<KVOContext>.fromOpaque(context!).takeUnretainedValue().callHandler(change: change)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	/* Two contexts are equal iff the observed objects and key paths of the
	 * contexts are the same. If any of the observed objects has been deallocated
	 * the contexts are considered different. */
	private final class KVOContext : Equatable {
		
		static func ==(lhs: KVObserver.KVOContext, rhs: KVObserver.KVOContext) -> Bool {
			return (lhs.observedKeyPath == rhs.observedKeyPath && lhs.computedObservedObjectPtr == rhs.computedObservedObjectPtr)
		}
		
		var observedObject: NSObject? {
			if let o = observedObjectWeak {return o}
			if let p = observedObjectPtr {return Unmanaged<NSObject>.fromOpaque(p).takeUnretainedValue()}
			return nil
		}
		
		private var computedObservedObjectPtr: UnsafeMutableRawPointer? {
			if let o = observedObjectWeak {return Unmanaged.passUnretained(o).toOpaque()}
			return observedObjectPtr
		}
		
		let observedKeyPath: String
		
		init(object: NSObject, storeAsPointer: Bool, keyPath: String, dispatchType dt: DispatchType, willCallInitial: Bool, handler h: @escaping (_ change: [NSKeyValueChangeKey: Any]?) -> Void) {
			isInitialCall = willCallInitial
			
			if storeAsPointer {
				observedObjectPtr = Unmanaged.passUnretained(object).toOpaque()
				observedObjectWeak = nil
			} else {
				observedObjectWeak = object
				observedObjectPtr = nil
			}
			
			observedKeyPath = keyPath
			
			dispatchType = dt
			handler = h
			
			if dt.isOnCoreDataInferredContext {inferredContext = (object as! NSManagedObject).managedObjectContext!}
			else                              {inferredContext = nil}
		}
		
		func callHandler(change: [NSKeyValueChangeKey: Any]?) {
			defer {isInitialCall = false}
			
			switch (dispatchType, isInitialCall) {
			case (.direct, _), (.asyncDirectInitial, true), (.asyncOnMainQueueDirectInitial, true), (.coreDataAsyncDirectInitial, true), (.coreDataSyncDirectInitial, true),
			     (.coreDataInferredAsyncDirectInitial, true), (.coreDataInferredSyncDirectInitial, true):
				handler(change)
				
			case (.unsafeSync(let queue),  _):                         queue.sync{  self.handler(change) }
			case (.async(let queue), _):                               queue.async{ self.handler(change) }
			case (.asyncOnMainQueue, _):                  DispatchQueue.main.async{ self.handler(change) }
			case (.asyncDirectInitial(let queue), false):              queue.async{ self.handler(change) }
			case (.asyncOnMainQueueDirectInitial, false): DispatchQueue.main.async{ self.handler(change) }
			case (.directOrAsyncOnMainQueue, _):
				if Thread.isMainThread {handler(change)}
			   else                   {DispatchQueue.main.async{ self.handler(change) }}
				
			case (.coreDataSync(let context), _):                   context.performAndWait{ self.handler(change) }
			case (.coreDataSyncDirectInitial(let context), false):  context.performAndWait{ self.handler(change) }
			case (.coreDataAsync(let context), _):                  context.perform{ self.handler(change) }
			case (.coreDataAsyncDirectInitial(let context), false): context.perform{ self.handler(change) }
				
			case (.coreDataInferredSync, _),  (.coreDataInferredSyncDirectInitial, false):  inferredContext!.performAndWait{ self.handler(change) }
			case (.coreDataInferredAsync, _), (.coreDataInferredAsyncDirectInitial, false): inferredContext!.perform{ self.handler(change) }
			}
		}
		
		private var isInitialCall: Bool
		
		private let inferredContext: NSManagedObjectContext?
		
		/* An enum would be more beautiful, wouldn't you say? But we cannot store
		 * (beautifully) a weak reference in an enum ;) */
		private let observedObjectPtr: UnsafeMutableRawPointer?
		private weak var observedObjectWeak: NSObject?
		
		private let dispatchType: DispatchType
		private let handler: (_ change: [NSKeyValueChangeKey: Any]?) -> Void
		
	}
	
	private var currentObservingId = 0
	private var observingIdToContext = [ObservingId: KVOContext]()
	
}
