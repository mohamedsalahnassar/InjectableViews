//
//  InjectableContainerMacroTests.swift
//  InjectableViews
//
//  Created by mohammednassar on 29/07/2025.
//

import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import InjectableViews
@testable import InjectableViewsMacros

final class InjectableContainerMacroTests: XCTestCase {
    func testInjectableContainer() {
        assertMacroExpansion(
            """
            @InjectableContainer
            struct ParentView: View {
                @InjectableView
                var childViewBuilder: some View {
                    Text("Child View")
                }
            }
            """,
            expandedSource: """
                private var _overridesMaintainer = OverridesMaintainer()

                public enum InjectableKeys: String {
                    case childView = "childView"
                }

                public func overrideView<V: View>(for key: InjectableKeys, @ViewBuilder with viewBuilder: () -> V) -> Self {
                    _overridesMaintainer.updateOverride(for: key.rawValue, with: viewBuilder())
                    return self
                }
            """,
            macros: ["InjectableContainer": InjectableContainerMacro.self]
        )
    }

    func testNoInjectableViews() {
        assertMacroExpansion(
            """
            @InjectableContainer
            struct EmptyContainer: View {
                var body: some View {
                    Text("Empty")
                }
            }
            """,
            expandedSource: """
            struct EmptyContainer: View {
                var body: some View {
                    Text("Empty")
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "No `@InjectableView` annotated members found. The `InjectableContainer` macro requires at least one injectable view.", line: 1, column: 1),
                DiagnosticSpec(message: "No `@InjectableView` annotated members found.", line: 1, column: 1)
            ],
            macros: ["InjectableContainer": InjectableContainerMacro.self]
        )
    }
}
