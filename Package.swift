// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCodingEnvironment",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftCodingEnvironment",
            targets: ["SwiftCodingEnvironment"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", "1.1.4"..<"2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftCodingEnvironment",
            dependencies: [
                .product(name: "DequeModule", package: "swift-collections"),
            ]
        )
    ]
)
