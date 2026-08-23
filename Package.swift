// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "menu",
	platforms: [.macOS(.v26)],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
		.package(url: "https://github.com/ordo-one/FuzzyMatch.git", from: "1.0.0"),
	],
	targets: [
		.executableTarget(
			name: "menu",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "FuzzyMatch", package: "FuzzyMatch"),
			]
		),
		.testTarget(
			name: "menuTests",
			dependencies: ["menu"]
		),
	],
	swiftLanguageModes: [.v6]
)
