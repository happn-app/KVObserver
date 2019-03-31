// swift-tools-version:5.0
import PackageDescription


let package = Package(
	name: "KVObserver",
	products: [
		.library(name: "KVObserver", targets: ["KVObserver"]),
	],
	targets: [
		.target(name: "KVObserver", dependencies: []),
		.testTarget(name: "KVObserverTests", dependencies: ["KVObserver"])
	]
)
