# KVObserver
![Platforms](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS-lightgrey.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![SPM compatible](https://img.shields.io/badge/SPM-compatible-E05C43.svg?style=flat)](https://swift.org/package-manager/) [![License](https://img.shields.io/github/license/happn-tech/KVObserver.svg?style=flat)](License.txt) [![happn](https://img.shields.io/badge/from-happn-0087B4.svg?style=flat)](https://happn.com)

A safer KVO.

## Usage
Example:
```swift
let kvObserver = KVObserver()
let observedObject = ObservedObject()

/* Start observing observedObject */ 
let observingId = kvObserver.observe(object: observedObject, keyPath: #keyPath(ObservedObject.observableProperty), kvoOptions: [.initial], dispatchType: .asyncOnMainQueueDirectInitial, handler: { [weak self] change in
   /* Handle changes here */
})

/* End observing observedObject */ 
kvObserver.stopObserving(id: observingId)
/* Or, stop observing everything */
kvObserver.stopObservingEverything()
```

There are many dispatch types available, all of them with their subtle differences. Usually you’ll
need the default one: `.asyncOnMainQueueDirectInitial`. This will dispatch the inital KVO
firing synchronously (if there is one, that is if the `.inital` KVO option has been set), and further
KVO firing asynchronously on the main thread.

Don’t hesitate to read the code to learn about the other dispatch types! All of the types are
documented. There even are dispatch types specifically for CoreData.

## TODO
- [x] Re-registration skipping
- [ ] Support for Swift 4 `KeyPath`

## Credits
This project was originally created by [François Lamboley](https://github.com/Frizlab) while working at [happn](https://happn.com).
