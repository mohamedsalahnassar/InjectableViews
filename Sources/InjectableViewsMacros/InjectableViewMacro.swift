//
//  InjectableViewMacro.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 27/07/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// A macro that synthesizes a computed property accessor for SwiftUI view injection.
///
/// The `@InjectableView` macro adds a custom `get` accessor to properties, allowing views to be overridden at runtime
/// (using an internal `_viewOverrides` dictionary) or defaulting to a builder method following the `<propertyName>Builder` convention.
///
/// Usage:
///   Attach `@InjectableView` to a SwiftUI view property in a type that supports injection.
///   The macro generates logic to fetch an override if present, or build the default view otherwise.
///
/// - Note: Emits a compile-time error if used on anything other than a single variable declaration.
public struct InjectableViewMacro: AccessorMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            // Emit a macro diagnostic: only usable with variable declarations
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: InjectableViewMacroError.notSingleVariable
                )
            )
            return []
        }

        // Derive expected builder method name by convention: <propertyName>Builder
        let builderName = "\(name)Builder"

        // Compose the override + builder call logic
        // This assumes the builder exists; if not, the user gets a Swift compile error
        let computedBody = """
        get {
            if let overridden = _viewOverrides["\(name)"] { return AnyView(overridden) }
            return AnyView(\(builderName)())
        }
        """

        let accessor = try AccessorDeclSyntax(stringLiteral: computedBody)
        return [accessor]
    }
}

/// Macro errors for developer feedback
enum InjectableViewMacroError: DiagnosticMessage {
    case notSingleVariable

    var message: String {
        switch self {
        case .notSingleVariable:
            return "@InjectableView must attach to a variable declaration."
        }
    }

    var severity: DiagnosticSeverity { .error }
    var diagnosticID: MessageID {
        MessageID(domain: "InjectableViewMacro", id: "\(self)")
    }
}

