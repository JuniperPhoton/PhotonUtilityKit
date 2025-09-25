// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotonUtilityKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PhotonUtilityKit",
            targets: [
                "PhotonUtility",
                "PhotonUtilityView",
                "PhotonLegacyCompat"
            ]
        ),
        .library(
            name: "PhotonUtilityKit-Static",
            type: .static,
            targets: [
                "PhotonUtility",
                "PhotonUtilityView",
                "PhotonLegacyCompat"
            ]
        ),
        .library(
            name: "PhotonUtilityKit-Dynamic",
            type: .dynamic,
            targets: [
                "PhotonUtility",
                "PhotonUtilityView",
                "PhotonLegacyCompat"
            ]
        ),
    ],
    dependencies: [
        // empty
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PhotonUtility",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]),
        .target(
            name: "PhotonUtilityView",
            dependencies: [
                "PhotonUtility",
                "PhotonLegacyCompat",
            ]
        ),
        .target(
            name: "PhotonLegacyCompat",
        ),
        .testTarget(
            name: "PhotonUtilityKitTests",
            dependencies: ["PhotonUtility"]
        )
    ]
)
