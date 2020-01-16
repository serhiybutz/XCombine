// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "XCombine",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "XCombine",
            targets: ["XCombine"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XCombine",
            dependencies: []),
        .testTarget(
            name: "XCombineTests",
            dependencies: ["XCombine"])
    ],
    swiftLanguageVersions: [.v5]
)
