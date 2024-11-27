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
                "PhotonUtilityLayout",
                "PhotonUtilityView"
            ]
        ),
        .library(
            name: "PhotonUtilityKit-Static",
            type: .static,
            targets: [
                "PhotonUtility",
                "PhotonUtilityLayout",
                "PhotonUtilityView"
            ]
        ),
        .library(
            name: "PhotonUtilityKit-Dynamic",
            type: .dynamic,
            targets: [
                "PhotonUtility",
                "PhotonUtilityLayout",
                "PhotonUtilityView"
            ]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.2.0"),
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
            name: "PhotonUtilityLayout",
            dependencies: ["PhotonUtility"]),
        .target(
            name: "PhotonUtilityView",
            dependencies: ["PhotonUtility", .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")]
        ),
        .testTarget(name: "PhotonUtilityKitTests",
                    dependencies: ["PhotonUtility"])
    ]
)
