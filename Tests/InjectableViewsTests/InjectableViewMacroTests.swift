//
//  InjectableViewMacroTests.swift
//  InjectableViews
//
//  Created by mohammednassar on 29/07/2025.
//


import SwiftSyntaxMacrosTestSupport
import SwiftCompilerPlugin
import SwiftCompilerPluginMessageHandling
import XCTest
@testable import InjectableViews
@testable import InjectableViewsMacros

final class InjectableViewMacroTests: XCTestCase {
    
//    func testInjectableViewVariable1() {
//        let actualSource = expandMacro(
//            """
//            @InjectableView
//            var childViewBuilder: some View {
//                Text("Child View")
//            }
//            """,
//            macros: ["InjectableView": InjectableViewMacro.self]
//        )
//        print("Actual Output:\n\(actualSource)")
//        XCTAssertEqual(actualSource, """
//        var childView: some View {
//            if let override = _overridesMaintainer.override(for: "childView") {
//                return override
//            }
//            return AnyView(childViewBuilder)
//        }
//        """)
//
//    }
//
    func testInjectableViewVariable() {
        assertMacroExpansion(
            """
            @InjectableView
            var childViewBuilder: some View {
                Text("Child View")
            }
            """,
            expandedSource: """
            var childView: some View {
                if let override = _overridesMaintainer.override(for: "childView") {
                    return override
                }
                return AnyView(childViewBuilder)
            }
            """,
            macros: ["InjectableView": InjectableViewMacro.self]
        )
    }

    func testInjectableViewFunction() {
        assertMacroExpansion(
            """
            @InjectableView
            func childViewBuilder() -> some View {
                Text("Child View")
            }
            """,
            expandedSource: """
            var childView: some View {
                if let override = _overridesMaintainer.override(for: "childView") {
                    return override
                }
                return AnyView(childViewBuilder())
            }
            """,
            macros: ["InjectableView": InjectableViewMacro.self]
        )
    }

    func testInjectableViewVariableWithCustomName() {
        assertMacroExpansion(
            """
            @InjectableView("customChildView")
            var childViewBuilder: some View {
                Text("Child View")
            }
            """,
            expandedSource: """
            var customChildView: some View {
                if let override = _overridesMaintainer.override(for: "customChildView") {
                    return override
                }
                return AnyView(childViewBuilder)
            }
            """,
            macros: ["InjectableView": InjectableViewMacro.self]
        )
    }

    func testInjectableViewFunctionWithCustomName() {
        assertMacroExpansion(
            """
            @InjectableView("customChildView")
            func childViewBuilder() -> some View {
                Text("Child View")
            }
            """,
            expandedSource: """
            var customChildView: some View {
                if let override = _overridesMaintainer.override(for: "customChildView") {
                    return override
                }
                return AnyView(childViewBuilder())
            }
            """,
            macros: ["InjectableView": InjectableViewMacro.self]
        )
    }

    func testInvalidIdentifier() {
        assertMacroExpansion(
            """
            @InjectableView
            var invalidName: some View {
                Text("Invalid")
            }
            """,
            expandedSource: """
            var invalidName: some View {
                Text("Invalid")
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "The name must end with 'Builder' to use @InjectableView.", line: 1, column: 1)
            ],
            macros: ["InjectableView": InjectableViewMacro.self]
        )
    }
}
