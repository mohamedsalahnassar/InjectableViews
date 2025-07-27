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

/// A macro that injects a public `@Environment` property for runtime dependency overrides into SwiftUI container views.
///
/// This macro is intended for use on SwiftUI container views that require type-safe, runtime-injectable view-specific overrides.
/// It injects a publicly accessible `@Environment(\._viewOverrides)` property named `_viewOverrides`, 
/// which provides access to a dictionary of view overrides used for dependency injection.
///
/// Usage:
/// ```swift
/// @InjectableContainer
/// struct MyView: View {
///     // The macro injects:
///     // @Environment(\._viewOverrides) public var _viewOverrides
///     ...
/// }
/// ```
///
/// The injected property enables flexible and type-safe dependency injection for testing or feature variations.
///
/// - Author: Mohamed Nassar
/// - Since: 27/07/2025
public struct InjectableContainerMacro: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Inject a public @Environment property for view overrides dictionary
        let overridesProperty = try DeclSyntax(stringLiteral: "@Environment(\\._viewOverrides) public var _viewOverrides")
        return [overridesProperty]
    }
}
