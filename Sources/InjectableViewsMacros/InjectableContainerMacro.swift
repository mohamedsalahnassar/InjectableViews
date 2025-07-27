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

/// A macro that injects a property for runtime dependency overrides into SwiftUI container views.
///
/// This macro is intended to be used as a `@MemberMacro` on SwiftUI containers that require
/// dependency injection capabilities. When applied, it adds an `@Environment` variable that stores
/// view-specific overrides, enabling flexible injection of dependencies for testing or feature variation.
///
/// Usage:
/// ```swift
/// @InjectableContainerMacro
/// struct MyView: View {
///     // ...
/// }
/// ```
///
/// The injected `_viewOverrides` property provides access to the current view's overrides dictionary.
///
/// - Author: Mohamed Nassar
/// - Since: 27/07/2025
public struct InjectableContainerMacro: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Inject a dictionary property for overrides
        let overridesProperty = try DeclSyntax(stringLiteral: "@Environment(\\._viewOverrides) public var _viewOverrides")
        return [overridesProperty]
    }
}

