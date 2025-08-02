//
//  InjectableContainerMacro.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 27/07/2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftDiagnostics

/// A macro that injects runtime dependency management capabilities into SwiftUI container views.
///
/// The `@InjectableContainer` macro is designed to be applied to SwiftUI container views that require
/// dependency injection for child views. It works in conjunction with the `@InjectableView` macro, which
/// marks specific computed properties or functions as injectable views.
///
/// ### Key Features:
/// - **Runtime Overrides**: Injects a private `_overridesMaintainer` property to manage runtime view overrides.
/// - **Type-Safe Keys**: Generates an `InjectableKeys` enum containing all injectable views for type-safe key management.
/// - **Override Functionality**: Adds an `overrideView(for:with:)` function to allow runtime overrides of views.
///
/// ### Requirements:
/// - The container must conform to `View`.
/// - Child views must be marked with `@InjectableView` and implemented as computed properties or functions.
/// - The names of injectable views must end with "Builder" (e.g., `childViewBuilder`).
///
/// ### Example Usage:
///
/// #### Defining a Container View:
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
/// #### Generated Members:
/// The macro generates the following members:
/// ```swift
/// private var _overridesMaintainer = OverridesMaintainer()
///
/// public func overrideView<V: View>(for key: InjectableKeys, @ViewBuilder with viewBuilder: () -> V) -> Self {
///     _overridesMaintainer.updateOverride(for: key.rawValue, with: AnyView(viewBuilder()))
///     return self
/// }
///
/// public enum InjectableKeys: String {
///     case childView = "childView"
///     case anotherChildView = "anotherChildView"
/// }
/// ```
///
/// - Note: This macro must be applied to a `struct` or `class` that conforms to `View`.
/// - Author: Mohamed Nassar
/// - Since: 27/07/2025
public struct InjectableContainerMacro: MemberMacro {
    /// Expands the macro to inject runtime dependency management members into the container.
    ///
    /// - Parameters:
    ///   - attribute: The attribute syntax where the macro is applied.
    ///   - declaration: The declaration to which the macro is attached.
    ///   - context: The macro expansion context.
    /// - Returns: An array of `DeclSyntax` representing the injected members.
    /// - Throws: An error if the macro expansion fails.
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Inject a property for the overrides maintainer
        let overridesMaintainerProperty = try DeclSyntax(stringLiteral: """
        private let _overridesMaintainer = OverridesMaintainer()
        """)

        // Generate the InjectableKeys enum
        let injectableKeysEnum = try generateInjectableKeysEnum(from: declaration, in: context)

        // Inject a function to update the overrides
        let updateFunction = try DeclSyntax(stringLiteral: """
        public func overrideView<V: View>(for key: InjectableKeys, @ViewBuilder with viewBuilder: () -> V) -> Self {
            _overridesMaintainer.updateOverride(for: key.rawValue, with: AnyView(viewBuilder()))
            return self
        }
        """)

        return [overridesMaintainerProperty, injectableKeysEnum, updateFunction]
    }

    /// Generates the `InjectableKeys` enum based on `@InjectableView` annotated members.
    ///
    /// - Parameters:
    ///   - declaration: The declaration group syntax of the container.
    ///   - context: The macro expansion context.
    /// - Returns: A `DeclSyntax` representing the generated enum.
    /// - Throws: An error if the enum generation fails.
    private static func generateInjectableKeysEnum(
        from declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> DeclSyntax {
        // Collect all injectable members (computed properties or functions ending with "Builder")
        let injectableMembers = declaration.memberBlock.members.compactMap { member -> String? in
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               let binding = varDecl.bindings.first,
               let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
               identifier.hasSuffix("Builder") {
                return String(identifier.dropLast("Builder".count))
            }

            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               funcDecl.identifier.text.hasSuffix("Builder") {
                return String(funcDecl.identifier.text.dropLast("Builder".count))
            }

            return nil
        }

        // Emit an error if no injectable members are found
        if injectableMembers.isEmpty {
            context.diagnose(
                Diagnostic(
                    node: declaration._syntaxNode,
                    message: InjectableContainerMacroError.noInjectableViewsFound
                )
            )
            throw MacroExpansionError(message: "No `@InjectableView` annotated members found.")
        }

        // Generate the enum cases
        let cases = injectableMembers.map { "case \($0) = \"\($0)\"" }.joined(separator: "\n")
        let enumSyntax = """
        public enum InjectableKeys: String {
            \(cases)
        }
        """
        return try DeclSyntax(stringLiteral: enumSyntax)
    }
}

/// Custom error type for macro expansion errors.
struct MacroExpansionError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

/// Diagnostic messages for `InjectableContainerMacro`.
enum InjectableContainerMacroError: DiagnosticMessage {
    case noInjectableViewsFound

    var message: String {
        switch self {
        case .noInjectableViewsFound:
            return "No `@InjectableView` annotated members found. The `InjectableContainer` macro requires at least one injectable view."
        }
    }

    var severity: DiagnosticSeverity { .error }

    var diagnosticID: MessageID {
        MessageID(domain: "InjectableContainerMacro", id: "\(self)")
    }
}
