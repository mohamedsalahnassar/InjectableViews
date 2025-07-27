//
//  InjectableViewsPlugin.swift
//  InjectableViews
//
//  Created by Mohamed Nassar on 27/07/2025.
//


import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// The main entry point for the InjectableViews Swift compiler plugin.
///
/// `InjectableViewsPlugin` registers the macros provided by the `InjectableViews` package
/// with the Swift compiler, enabling their use in client code. By conforming to `CompilerPlugin`
/// and being marked with the `@main` attribute, this struct ensures that the compiler
/// recognizes and loads the macros at build time.
///
/// The macros listed in `providingMacros`—such as `InjectableViewMacro` and `InjectableContainerMacro`—
/// are made available for use in source code, supporting advanced code generation and injection patterns.
@main
struct InjectableViewsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectableViewMacro.self,
        InjectableContainerMacro.self
    ]
}
