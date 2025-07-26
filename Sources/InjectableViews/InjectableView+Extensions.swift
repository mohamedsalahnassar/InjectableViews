import SwiftUI

public class InjectableRegistry: ObservableObject {
    @Published var overrides: [String: ()->AnyView] = [:]
    public func override<Content: View>(_ key: String, with builder: @escaping ()->Content) {
        overrides[key] = { AnyView(builder()) }
    }
    public func resolve<Content: View>(key: String, default defaultBuilder: @escaping ()->Content) -> AnyView {
        if let o = overrides[key] { return o() } else { return AnyView(defaultBuilder()) }
    }
}

private struct InjectableRegistryKey: EnvironmentKey {
    static let defaultValue = InjectableRegistry()
}

public extension EnvironmentValues {
    var injectableRegistry: InjectableRegistry {
        get { self[InjectableRegistryKey.self] }
        set { self[InjectableRegistryKey.self] = newValue }
    }
}

public struct InjectableProvider<Content: View>: View {
    @StateObject private var registry = InjectableRegistry()
    let content: Content
    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    public var body: some View {
        content.environment(\.injectableRegistry, registry)
    }
}

// OverrideViewModifier
private struct OverrideViewModifier<Replacement: View>: ViewModifier {
    @Environment(\.injectableRegistry) private var registry
    let key: String
    let builder: () -> Replacement
    func body(content: Content) -> some View {
        content.onAppear { registry.override(key, with: builder) }
    }
}

public extension View {
    func overrideView<Replacement: View>(_ key: String, @ViewBuilder with builder: @escaping () -> Replacement) -> some View {
        modifier(OverrideViewModifier(key: key, builder: builder))
    }
}
