# InjectableViews

[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-15%2B-blue?logo=xcode)](https://developer.apple.com/xcode/)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2015%2B%20%7C%20macOS%2012%2B%20%7C%20tvOS%2015%2B%20%7C%20watchOS%208%2B-lightgrey?logo=apple)](https://developer.apple.com/documentation/swiftui)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

`InjectableViews` is a Swift package designed to simplify dependency injection and view customization in **SwiftUI** applications. It leverages Swift macros to reduce boilerplate code and enhance the flexibility of view hierarchies.

## Features

- **Dependency Injection for Views**: Easily inject and override views at runtime or during testing.
- **Swift Macros**: Use `@InjectableView` and `@InjectableContainer` macros to enable code generation and dependency management.
- **Customizable View Hierarchies**: Override specific views in a hierarchy without modifying the original implementation.
- **Improved Testability**: Simplify testing by injecting mock views or dependencies.
- **SwiftUI-First Design**: Built exclusively for SwiftUI projects.

## Requirements

- **Swift**: 5.9 or later
- **Xcode**: 15 or later
- **Platforms**: iOS 15+, macOS 12+, tvOS 15+, watchOS 8+

## Installation

Add `InjectableViews` to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/mohamedsalahnassar/InjectableViews.git", from: "1.0.2")
]
```

Then, import the package in your SwiftUI project:

```swift
import InjectableViews
```

## Usage

### 1. Mark a View as Injectable

Use the `@InjectableView` macro to mark a property or function as an injectable view. The property or function name must end with "Builder" to be processed by the macro. Optionally, you can pass a string argument to specify a custom computed-property name.

#### Example: Attaching to a Computed Property

```swift
@InjectableContainer
struct ParentView: View {
    @InjectableView
    var childViewBuilder: some View {
        Text("Default Child View")
    }

    var body: some View {
        VStack {
            childView
        }
    }
}
```

#### Example: Attaching to a Function

```swift
@InjectableContainer
struct ParentView: View {
    @InjectableView
    func childViewBuilder() -> some View {
        Text("Default Child View")
    }

    var body: some View {
        VStack {
            childView
        }
    }
}
```

The macro generates a computed property that checks for runtime overrides using the `_overridesMaintainer` object. If no override exists, it falls back to the default builder method or property.

#### Example: Custom Property Name

You can optionally supply a custom property name to the `@InjectableView` macro. When an argument is provided, that name is used for the generated computed property instead of inferring it from the `Builder` suffix.

```swift
@InjectableContainer
struct ParentView: View {
    @InjectableView("customChildView")
    func childViewBuilder() -> some View {
        Text("Default Child View")
    }

    var body: some View {
        VStack {
            customChildView
        }
    }
}
```

### 2. Define a Container View

Use the `@InjectableContainer` macro to mark a container view that manages injectable child views. The macro generates the following members:
- A private `_overridesMaintainer` property to manage runtime overrides.
- A `overrideView(for:with:)` function to allow runtime view overrides.
- An `InjectableKeys` enum containing all injectable properties or functions for type-safe key management.

#### Example: Container View

```swift
@InjectableContainer
struct ParentView: View {
    @InjectableView
    var childViewBuilder: some View {
        Text("Default Child View")
    }

    @InjectableView
    func anotherChildViewBuilder() -> some View {
        Text("Another Default Child View")
    }

    var body: some View {
        VStack {
            childView
            anotherChildView
        }
    }
}
```

The macro generates the following members:

```swift
private var _overridesMaintainer = OverridesMaintainer()

public func overrideView<V: View>(for key: InjectableKeys, @ViewBuilder with viewBuilder: () -> V) -> Self {
    _overridesMaintainer.updateOverride(for: key.rawValue, with: AnyView(viewBuilder()))
    return self
}

public enum InjectableKeys: String {
    case childView = "childView"
    case anotherChildView = "anotherChildView"
}
```

### 3. Override Views in a Hierarchy

Use the `overrideView` function to replace specific views in a hierarchy. The function supports a **builder pattern**, allowing you to chain multiple overrides.

#### Example: Overriding Views

```swift
struct CustomParentView: View {
    var body: some View {
        ParentView()
            .overrideView(for: .childView) {
                Text("Overridden Child View")
                    .padding()
                    .background(Color.yellow.opacity(0.3))
            }
            .overrideView(for: .anotherChildView) {
                Text("Overridden Another Child View")
                    .padding()
                    .background(Color.orange.opacity(0.3))
            }
    }
}
```

### 4. Example Application

Here’s an example of how to use `InjectableViews` in a SwiftUI app:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Original View")
                ParentView()

                Text("Customized View")
                CustomParentView()
            }
        }
    }
}
```

## Diagnostics and Error Handling

The macros provide detailed diagnostics to help developers identify and fix issues during compilation:

- **`@InjectableView` Errors**:
  - The name must end with "Builder".
  - The variable declaration must have a valid binding.
  - The function declaration must have a body.

- **`@InjectableContainer` Errors**:
  - No `@InjectableView` annotated members found. The container must have at least one injectable view.

## Changes in the Latest Version

1. **Enhanced Diagnostics**: Improved error messages for macros to provide better feedback during compilation.
2. **Builder Pattern for `overrideView`**: The `overrideView` function now returns `Self`, enabling chaining of multiple overrides.
3. **Renamed `OverridesManager` to `OverridesMaintainer`**: All references to `OverridesManager` have been updated to `OverridesMaintainer`.

## Motivation

`InjectableViews` was created to streamline dependency injection in SwiftUI, reduce boilerplate code, and improve the modularity and testability of view-based architectures.

## License

This project is licensed under the terms of the MIT license. See the `LICENSE` file for details.
```
