// swift-tools-version:5.0
import PackageDescription


let package = Package(
	name: "KVObserver",
	platforms: [
		.macOS(.v10_10),
		.iOS(.v8),
		.tvOS(.v9),
		.watchOS(.v2)
	],
	products: [
		.library(name: "KVObserver", targets: ["KVObserver"]),
	],
	targets: [
		.target(name: "KVObserver", dependencies: []),
		.testTarget(name: "KVObserverTests", dependencies: ["KVObserver"])
	]
)
