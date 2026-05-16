// swift-tools-version: 5.9
// SwiftMacrosKit — 100 production-grade Swift Macros for Apple ecosystem development.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftMacrosKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "SwiftMacrosKit",
            targets: ["SwiftMacrosKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "SwiftMacrosKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftMacrosKit",
            dependencies: ["SwiftMacrosKitMacros"]
        ),
        .testTarget(
            name: "SwiftMacrosKitTests",
            dependencies: [
                "SwiftMacrosKit",
                "SwiftMacrosKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
