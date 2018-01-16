// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
	name: "KVObserver",
	products: [
		.library(
			name: "KVObserver",
			targets: ["KVObserver"]
		)
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "KVObserver",
			dependencies: []
		),
		.testTarget(
			name: "KVObserverTests",
			dependencies: ["KVObserver"]
		)
	]
)
