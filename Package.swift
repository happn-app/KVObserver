// swift-tools-version:4.0

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
