// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "InjectableViews",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "InjectableViews",
            targets: ["InjectableViews"]
        ),
        .executable(
            name: "InjectableViewsDemo",
            targets: ["InjectableViewsDemo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "InjectableViewsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder",  package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "InjectableViews",
            dependencies: ["InjectableViewsMacros"]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "InjectableViewsDemo",
            dependencies: ["InjectableViews"]
        ),

        .testTarget(
            name: "InjectableViewsTests",
            dependencies: [
                "InjectableViews",
                "InjectableViewsMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),

            ],
            path: "Tests/InjectableViewsTests"
        )
    ]
)
