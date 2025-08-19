//
//  MacroDefinitions.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 26/07/2025.
//

import SwiftUI

/// Marks a type (typically a container view or parent view) as injectable for the InjectableViews system.
///
/// Use this macro to enable dependency injection for child views that are marked with `@InjectableView` within the container.
/// The macro injects the following members into the annotated type:
/// - A private `_overridesMaintainer` property to manage runtime overrides.
/// - A `overrideView(for:with:)` function to allow runtime view overrides.
/// - An `InjectableKeys` enum containing all injectable properties or functions for type-safe key management.
///
/// ### Example Usage:
///
/// #### Attaching to a Container View:
/// ```swift
/// @InjectableContainer
/// struct ParentView: View {
///     @InjectableView
///     var childView: some View {
///         Text("Default Child View")
///     }
///
///     @InjectableView
///     func anotherChildViewBuilder() -> some View {
///         Text("Another Default Child View")
///     }
///
///     var body: some View {
///         VStack {
///             childView
///             anotherChildViewBuilder()
///         }
///     }
/// }
/// ```
///
/// #### Generated Members:
/// The macro generates the following members:
/// ```swift
/// private var _overridesMaintainer = OverridesMaintainer()
///
/// public func overrideView<V: View>(for key: InjectableKeys, @ViewBuilder with viewBuilder: () -> V) async -> Self {
///     await _overridesMaintainer.updateOverride(for: key.rawValue, with: AnyView(viewBuilder()))
///     return self
/// }
///
/// public enum InjectableKeys: String {
///     case childView = "childView"
///     case anotherChildView = "anotherChildView"
/// }
/// ```
///
/// #### Overriding Views:
/// ```swift
/// struct CustomParentView: View {
///     var body: some View {
///         ParentView()
///             .overrideView(for: .childView) {
///                 Text("Overridden Child View")
///                     .padding()
///                     .background(Color.yellow.opacity(0.3))
///             }
///             .overrideView(for: .anotherChildView) {
///                 Text("Overridden Another Child View")
///                     .padding()
///                     .background(Color.orange.opacity(0.3))
///             }
///     }
/// }
/// ```
///
/// - Note: This macro must be applied to a `struct` or `class` that conforms to `View`.
/// - Author: Mohamed Nassar
/// - Since: 26/07/2025
@attached(member, names: named(_overridesMaintainer), named(overrideView(for:with:)), named(InjectableKeys))
public macro InjectableContainer() = #externalMacro(
    module: "InjectableViewsMacros",
    type: "InjectableContainerMacro"
)

/// Marks a computed property or function as an injectable view within a container marked with `@InjectableContainer`.
///
/// Use this macro to enable injection or override of the specified view at runtime or in tests. The macro generates a computed property
/// that checks for runtime overrides using the `_overridesMaintainer` object. If no override exists, it falls back to the default builder method or property.
///
/// ### Requirements:
/// - The property or function name must end with "Builder".
/// - The property type must conform to `View`.
///
/// ### Example Usage:
///
/// #### Attaching to a Computed Property:
/// ```swift
/// @InjectableContainer
/// struct ParentView: View {
///     @InjectableView var childView: some View {
///         Text("Default Child View")
///     }
///
///     var body: some View {
///         VStack {
///             childView
///         }
///     }
/// }
/// ```
///
/// #### Attaching to a Function:
/// ```swift
/// @InjectableContainer
/// struct ParentView: View {
///     @InjectableView
///     func childViewBuilder() -> some View {
///         Text("Default Child View")
///     }
///
///     var body: some View {
///         VStack {
///             childViewBuilder()
///         }
///     }
/// }
/// ```
///
/// #### Generated Computed Property:
/// The macro generates the following computed property for the above examples:
/// ```swift
/// var childView: some View {
///     get async {
///         if let override = await _overridesMaintainer.override(for: "childView") {
///             return override
///         }
///         return AnyView(childViewBuilder())
///     }
/// }
/// ```
///
/// - Note: This macro must be applied to a computed property or function within a type marked with `@InjectableContainer`.
/// - Author: Mohamed Nassar
/// - Since: 26/07/2025
@attached(peer, names: arbitrary)
public macro InjectableView() = #externalMacro(
    module: "InjectableViewsMacros",
    type: "InjectableViewMacro"
)
