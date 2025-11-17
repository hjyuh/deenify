// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeenifyApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "DeenifyApp",
            targets: ["DeenifyApp"]
        )
    ],
    dependencies: [
        // Add package dependencies here if needed
        // Example: .package(url: "https://github.com/foo/bar.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "DeenifyApp",
            dependencies: [],
            path: "Sources"
        )
    ]
)
