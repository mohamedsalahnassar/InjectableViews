import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics
import SwiftCompilerPlugin


@main
struct InjectableViewsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectableViewMacro.self,
    ]
}

/// Core macro implementation: generates stored properties, init, and accessors.
public struct InjectableViewMacro: MemberMacro, AccessorMacro {
    // MARK: MemberMacro
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              varDecl.bindings.count == 1,
              let binding = varDecl.bindings.first
        else {
            let diag = Diagnostic(node: Syntax(declaration), message: InjectableViewMacroError.notSingleVariable)
            throw DiagnosticsError(diagnostics: [diag])
        }
        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            let diag = Diagnostic(node: Syntax(binding), message: InjectableViewMacroError.notSingleVariable)
            throw DiagnosticsError(diagnostics: [diag])
        }
        guard let initExpr = binding.initializer?.value else {
            let diag = Diagnostic(node: Syntax(binding), message: InjectableViewMacroError.missingInitializer)
            throw DiagnosticsError(diagnostics: [diag])
        }
        let backing = "_\(name)_override"
        let defaultVal = initExpr.description.trimmingCharacters(in: .whitespacesAndNewlines)
        return [
            "@State private var \(raw: backing): AnyView? = nil",
            "private let _\(raw: name)_default: ()->AnyView = { AnyView(\(raw: defaultVal)) }",
            "public init(wrappedValue defaultBuilder: @escaping ()->some View) { self._\(raw: name)_default = { AnyView(defaultBuilder()) } }"
        ]
    }

    // MARK: AccessorMacro
    public static func expansion(
        of attribute: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else {
            let diag = Diagnostic(node: Syntax(declaration), message: InjectableViewMacroError.notSingleVariable)
            throw DiagnosticsError(diagnostics: [diag])
        }
        let backing = "_\(name)_override"
        let defaultName = "_\(name)_default"
        return [
            AccessorDeclSyntax("""
get {
    if let o = \(raw: backing) { return o }
    return \(raw: defaultName)()
}
"""),
            AccessorDeclSyntax("""
set { \(raw: backing) = newValue }
""")
        ]
    }
}

/// Diagnostic errors for the macro.
enum InjectableViewMacroError: DiagnosticMessage {
    case notSingleVariable
    case missingInitializer

    var message: String {
        switch self {
        case .notSingleVariable:
            return "@InjectableView must attach to exactly one variable declaration."
        case .missingInitializer:
            return "@InjectableView requires an initializer closure (e.g. `= { ... }`)."
        }
    }

    var severity: DiagnosticSeverity { .error }
    var diagnosticID: MessageID {
        MessageID(domain: "InjectableViewMacro", id: "\(self)")
    }
}

fileprivate extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
