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
/// The generated accessor always returns `some View`, wrapping builder results in `AnyView` to hide type erasure,
/// and returning override closures' results directly (which are expected to be `AnyView`).
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
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: declaration, message: InjectableViewMacroError.notVariableDeclaration))
            return []
        }
        
        guard varDecl.bindings.count == 1,
              let binding = varDecl.bindings.first,
              let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            context.diagnose(Diagnostic(node: declaration, message: InjectableViewMacroError.notSingleVariable))
            return []
        }
        
        let propertyName = identifierPattern.identifier.text
        
        // Validate that the variable has a type annotation.
        guard binding.typeAnnotation != nil else {
            context.diagnose(Diagnostic(node: declaration, message: InjectableViewMacroError.missingTypeAnnotation))
            return []
        }
        
        // Derive expected builder method name by convention: <propertyName>Builder
        let builderName = "\(propertyName)Builder"
        
        // Compose the override + builder call logic.
        // The accessor returns some View:
        // - If an override closure exists in _viewOverrides, call it and return its result (AnyView).
        // - Otherwise, call the builder and wrap its result in AnyView.
        let computedBody = """
        get {
            if let override = _viewOverrides["\(propertyName)"] {
                return override()
            }
            return AnyView(\(builderName)())
        }
        """
        
        let accessor = try AccessorDeclSyntax(stringLiteral: computedBody)
        return [accessor]
    }
}

/// Macro errors for developer feedback
enum InjectableViewMacroError: DiagnosticMessage {
    case notVariableDeclaration
    case notSingleVariable
    case missingTypeAnnotation

    var message: String {
        switch self {
        case .notVariableDeclaration:
            return "@InjectableView must attach to a variable declaration."
        case .notSingleVariable:
            return "@InjectableView must be attached to a single variable declaration."
        case .missingTypeAnnotation:
            return "@InjectableView variable must have an explicit type annotation."
        }
    }

    var severity: DiagnosticSeverity { .error }
    var diagnosticID: MessageID {
        MessageID(domain: "InjectableViewMacro", id: "\(self)")
    }
}
