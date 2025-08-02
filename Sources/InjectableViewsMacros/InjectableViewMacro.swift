//
//  InjectableViewMacro.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 27/07/2025.
//

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

/// A macro that generates computed properties for injectable views in SwiftUI.
///
/// The `@InjectableView` macro is used to mark properties or functions as injectable views within a container.
/// It generates a computed property that checks for runtime overrides using the `_overridesMaintainer` object.
/// If no override exists, it falls back to the default builder method or property.
///
/// ### Example Usage:
/// ```swift
/// @InjectableContainer
/// struct ParentView: View {
///     @InjectableView var childView: some View
///
///     func childViewBuilder() -> some View {
///         Text("Default Child View")
///     }
/// }
/// ```
///
/// The macro generates the following computed property:
/// ```swift
/// var childView: some View {
///     if let override = _overridesMaintainer.override(for: "childView") {
///         return override
///     }
///     return childViewBuilder()
/// }
/// ```
///
/// - Note: The property or function name must end with "Builder" to be processed by this macro.
/// - Author: Mohamed Nassar
/// - Since: 27/07/2025
public struct InjectableViewMacro: PeerMacro {
    /// Expands the macro to generate computed properties for injectable views.
    ///
    /// - Parameters:
    ///   - node: The attribute syntax node where the macro is applied.
    ///   - declaration: The declaration to which the macro is attached (variable or function).
    ///   - context: The macro expansion context.
    /// - Returns: An array of `DeclSyntax` representing the generated computed properties.
    /// - Throws: An error if the macro is applied to an unsupported declaration or if validation fails.
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Handle variable declarations
        if let varDecl = declaration.as(VariableDeclSyntax.self) {
            return try processVariable(varDecl, in: context)
        }

        // Handle function declarations
        if let funcDecl = declaration.as(FunctionDeclSyntax.self) {
            return try processFunction(funcDecl, in: context)
        }

        // Emit an error for unsupported declaration types
        context.diagnose(Diagnostic(node: declaration, message: InjectableViewMacroError.notVariableOrFunction))
        return []
    }

    /// Processes a variable declaration to generate a computed property.
    ///
    /// - Parameters:
    ///   - varDecl: The variable declaration syntax.
    ///   - context: The macro expansion context.
    /// - Returns: An array of `DeclSyntax` representing the generated computed property.
    /// - Throws: An error if validation fails.
    private static func processVariable(
        _ varDecl: VariableDeclSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure the variable has a valid binding
        guard let binding = varDecl.bindings.first else {
            context.diagnose(Diagnostic(node: varDecl, message: InjectableViewMacroError.missingBinding))
            return []
        }

        // Ensure the variable has a valid identifier
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            context.diagnose(Diagnostic(node: varDecl, message: InjectableViewMacroError.invalidIdentifier))
            return []
        }

        // Ensure the identifier ends with "Builder"
        guard identifier.hasSuffix("Builder") else {
            context.diagnose(Diagnostic(node: varDecl, message: InjectableViewMacroError.invalidSuffix))
            return []
        }

        // Extract the property name by removing the "Builder" suffix
        let propertyName = String(identifier.dropLast("Builder".count))

        // Generate the computed property
        let computedProperty = try DeclSyntax(stringLiteral: """
        var \(propertyName): some View {
            if let override = _overridesMaintainer.override(for: "\(propertyName)") {
                return override
            }
            return AnyView(\(identifier))
        }
        """)

        return [computedProperty]
    }

    /// Processes a function declaration to generate a computed property.
    ///
    /// - Parameters:
    ///   - funcDecl: The function declaration syntax.
    ///   - context: The macro expansion context.
    /// - Returns: An array of `DeclSyntax` representing the generated computed property.
    /// - Throws: An error if validation fails.
    private static func processFunction(
        _ funcDecl: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract the function name
        let name = funcDecl.identifier.text

        // Ensure the function name ends with "Builder"
        guard name.hasSuffix("Builder") else {
            context.diagnose(Diagnostic(node: funcDecl, message: InjectableViewMacroError.invalidSuffix))
            return []
        }

        // Ensure the function has a body
        guard funcDecl.body != nil else {
            context.diagnose(Diagnostic(node: funcDecl, message: InjectableViewMacroError.missingFunctionBody))
            return []
        }

        // Extract the property name by removing the "Builder" suffix
        let propertyName = String(name.dropLast("Builder".count))

        // Generate the computed property
        let computedProperty = try DeclSyntax(stringLiteral: """
        var \(propertyName): some View {
            if let override = _overridesMaintainer.override(for: "\(propertyName)") {
                return override
            }
            return AnyView(\(name)())
        }
        """)

        return [computedProperty]
    }
}

/// Diagnostic messages for `InjectableViewMacro` errors.
///
/// These errors are emitted during macro expansion to provide feedback to developers.
enum InjectableViewMacroError: DiagnosticMessage {
    case notVariableOrFunction
    case invalidSuffix
    case missingBinding
    case invalidIdentifier
    case missingFunctionBody

    /// The error message to display to the developer.
    var message: String {
        switch self {
        case .notVariableOrFunction:
            return "@InjectableView can only be attached to a variable or function."
        case .invalidSuffix:
            return "The name must end with 'Builder' to use @InjectableView."
        case .missingBinding:
            return "The variable declaration must have a valid binding."
        case .invalidIdentifier:
            return "The variable declaration must have a valid identifier."
        case .missingFunctionBody:
            return "The function declaration must have a body."
        }
    }

    /// The severity of the diagnostic message.
    var severity: DiagnosticSeverity { .error }

    /// The unique identifier for the diagnostic message.
    var diagnosticID: MessageID {
        MessageID(domain: "InjectableViewMacro", id: "\(self)")
    }
}
