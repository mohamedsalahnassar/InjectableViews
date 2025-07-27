//
//  InjectableViews+Extensions.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 26/07/2025.
//

import SwiftUI

/// An environment key for storing view override mappings using string keys and `AnyView` values.
private struct ViewOverrideEnvironmentKey: EnvironmentKey {
    static let defaultValue: [String: AnyView] = [:]
}

/// An extension to `EnvironmentValues` to store and access view overrides.
public extension EnvironmentValues {
    /// A dictionary of string keys to override views of type `AnyView`.
    var _viewOverrides: [String: AnyView] {
        get { self[ViewOverrideEnvironmentKey.self] }
        set { self[ViewOverrideEnvironmentKey.self] = newValue }
    }
}

/// A view provider that injects custom view overrides into the environment for its content.
///
/// Use this to provide a set of view overrides within a view hierarchy.
public struct InjectableProvider<Content: View>: View {
    private let content: Content
    private let overrides: [String: AnyView]

    /// Creates an `InjectableProvider` with optional view overrides and content.
    /// - Parameters:
    ///   - overrides: A dictionary mapping string keys to `AnyView` overrides.
    ///   - content: A closure returning the content view.
    public init(overrides: [String: AnyView] = [:], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.overrides = overrides
    }

    /// The content with injected view overrides in the environment.
    public var body: some View {
        content.environment(\._viewOverrides, overrides)
    }
}

/// A view modifier to add or override a specific view in the environment using a key.
public struct InjectableOverrideModifier: ViewModifier {
    let key: String
    let view: AnyView
    @Environment(\._viewOverrides) private var existing

    /// Applies the view override to the environment for the given key.
    public func body(content: Content) -> some View {
        let merged = existing.merging([key: view]) { _, new in new }
        return content.environment(\._viewOverrides, merged)
    }
}

/// An extension on `View` to allow overriding a view for a given key within the current environment.
public extension View {
    /// Overrides a view in the environment for the given key.
    /// - Parameters:
    ///   - key: The key to associate with the view override.
    ///   - content: A closure providing the view to use as an override.
    /// - Returns: A modified view injecting the override.
    func overrideView(_ key: String, with content: @escaping () -> some View) -> some View {
        modifier(InjectableOverrideModifier(key: key, view: AnyView(content())))
    }
}
