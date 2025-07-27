//
//  InjectableViews+Extensions.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 26/07/2025.
//

import SwiftUI

/// An environment key for storing view override mappings using string keys and closures returning `AnyView` values.
/// 
/// Note: closures returning `AnyView` are used only at the override boundary to erase types.
/// Macro-generated code handles type checks and casting internally.
private struct ViewOverrideEnvironmentKey: EnvironmentKey {
    static let defaultValue: [String: () -> AnyView] = [:]
}

/// An extension to `EnvironmentValues` to store and access view overrides.
///
/// The overrides dictionary associates string keys with closures returning `AnyView` instances.
/// Type safety and casting are handled by macro-generated code at the edges.
public extension EnvironmentValues {
    /// A dictionary of string keys to override views of type closures returning `AnyView`.
    /// 
    /// Note: The closures here always return `AnyView` to erase types internally.
    /// User-facing APIs use `some View` and are wrapped automatically.
    var _viewOverrides: [String: () -> AnyView] {
        get { self[ViewOverrideEnvironmentKey.self] }
        set { self[ViewOverrideEnvironmentKey.self] = newValue }
    }
}

/// A view provider that injects custom view override closures into the environment for its content.
///
/// Use this to provide a set of view override closures within a view hierarchy.
///
/// - Parameters:
///   - overrides: A dictionary mapping string keys to closures returning `AnyView` overrides,
///     used internally for type erasure.
///   - content: A closure returning the content view.
/// 
/// Note: Users of this API typically don't create `AnyView` closures themselves; the system handles wrapping.
public struct InjectableProvider<Content: View>: View {
    private let content: Content
    private let overrides: [String: () -> AnyView]

    /// Creates an `InjectableProvider` with optional view override closures and content.
    /// - Parameters:
    ///   - overrides: A dictionary mapping string keys to closures returning `AnyView` overrides.
    ///   - content: A closure returning the content view.
    public init(overrides: [String: () -> AnyView] = [:], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.overrides = overrides
    }

    /// The content with injected view override closures in the environment.
    public var body: some View {
        content.environment(\._viewOverrides, overrides)
    }
}

/// A view modifier to add or override a specific view closure in the environment using a key.
///
/// The override closure is always stored as returning `AnyView` internally for type erasure.
/// Users of `.overrideView` do not need to wrap views in `AnyView` themselves.
public struct InjectableOverrideModifier: ViewModifier {
    let key: String
    let view: () -> AnyView
    @Environment(\._viewOverrides) private var existing

    /// Applies the view override closure to the environment for the given key.
    public func body(content: Content) -> some View {
        let merged = existing.merging([key: view]) { _, new in new }
        return content.environment(\._viewOverrides, merged)
    }
}

/// An extension on `View` to allow overriding a view for a given key within the current environment.
///
/// The override closure accepts `some View` from the user and is wrapped automatically in `AnyView`.
/// This means users never need to explicitly write `AnyView` in their override closures.
///
/// Example:
/// ```swift
/// .overrideView("emailField") {
///     Text("Override Email Field")
/// }
/// ```
public extension View {
    /// Overrides a view in the environment for the given key.
    /// - Parameters:
    ///   - key: The key to associate with the view override.
    ///   - content: A closure providing the view to use as an override.
    ///     The closure returns `some View` and is automatically wrapped in `AnyView`.
    /// - Returns: A modified view injecting the override closure.
    func overrideView(_ key: String, with content: @escaping () -> some View) -> some View {
        modifier(InjectableOverrideModifier(key: key, view: { AnyView(content()) }))
    }
}

/// Utility to help cast `AnyView` back to a specific view type.
/// 
/// This is optional and rarely needed, as macro-generated code manages type casting.
extension AnyView {
    func cast<T: View>(to type: T.Type) -> T? {
        self as? T
    }
}
