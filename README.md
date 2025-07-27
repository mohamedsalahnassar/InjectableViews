/// # InjectableViewsMacros
///
/// `InjectableViewsMacros` is a Swift macro package designed to simplify and enhance the development of views and view containers through code generation and dependency injection.
/// 
/// ## Features
/// - Declarative and concise creation of injectable views.
/// - Automatic generation of boilerplate for view hierarchy and dependency injection.
/// - Support for property wrappers and custom attributes to mark injectable views.
/// - Enhanced testability and separation of concerns for view-based architectures.
///
/// ## Usage
/// 1. Annotate your view types with the provided macros to enable code generation.
/// 2. Use the generated code to resolve view dependencies at runtime.
/// 3. Integrate with your existing SwiftUI, AppKit, or UIKit-based project for seamless injection.
///
/// ## Example
/// ```swift
/// @InjectableView
/// struct MyCustomView: View {
///     var body: some View {
///         Text("Hello, world!")
///     }
/// }
/// ```
///
/// ## Requirements
/// - Swift 5.9 or later
/// - Xcode 15 or later
///
/// ## Motivation
/// `InjectableViewsMacros` aims to reduce repetitive code, facilitate clean architecture, and streamline dependency management in modern Swift-based user interfaces.
///
/// ## License
/// See the LICENSE file for licensing information.
///
/// ---
 
