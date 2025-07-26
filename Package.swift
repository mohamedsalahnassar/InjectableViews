// swift-tools-version:5.9
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
        // 1) Your macro implementation
        .macro(
            name: "InjectableViewsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder",  package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // 2) Runtime helpers & extensions (must live under Sources/InjectableViews/)
        .target(
            name: "InjectableViews",
            dependencies: ["InjectableViewsMacros"]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "InjectableViewsDemo",
            dependencies: ["InjectableViews"]
        ),
    ]
)
