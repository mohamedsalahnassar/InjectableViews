//
//  InjectableView.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 26/07/2025.
//

import SwiftUI

/// Protocol for builder methods required by `@InjectableView` properties.
/// You must implement a method or closure conforming to this protocol for each injectable property.
public protocol InjectableViewBuilding {
    associatedtype Content: View
    func build() -> Content
}

/// Marks a type (typically a container view or parent view) as injectable for the InjectableViews system.
///
/// Use this macro to enable dependency injection for child views that are marked with `@InjectableView` within the container.
///
/// The macro attaches special member(s) to the annotated type to support view injection and overrides at runtime or test time.
///
/// Example:
/// ```swift
/// @InjectableContainer
/// struct ParentView: View {
///    ...
/// }
/// ```
@attached(member, names: named(_viewOverrides))
public macro InjectableContainer() = #externalMacro(
    module: "InjectableViewsMacros",
    type: "InjectableContainerMacro"
)

/// Marks a property as an injectable view within a container marked with `@InjectableContainer`.
///
/// Use this macro to enable injection or override of the specified view at runtime or in tests.
///
/// - Parameter key: An optional string to uniquely identify the injectable view. If omitted, the property name is used.
/// - Requirements: The property type must conform to `View`. For each injectable property, you must provide a builder method or closure named `<propertyName>Builder` that returns the correct type (matching the property type).
///
/// Example:
/// ```swift
/// @InjectableView
/// var child: ChildView
///
/// private func childBuilder() -> ChildView { ... }
/// ```
///
/// With a custom key:
/// ```swift
/// @InjectableView("customKey")
/// var anotherChild: SomeView
///
/// private func anotherChildBuilder() -> SomeView { ... }
/// ```
@attached(accessor)
public macro InjectableView(_ key: String? = nil) = #externalMacro(
    module: "InjectableViewsMacros",
    type: "InjectableViewMacro"
)
