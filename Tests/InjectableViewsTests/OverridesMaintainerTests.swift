import SwiftUI
import XCTest
@testable import InjectableViews

// A simple container that uses OverridesMaintainer directly for testing.
struct TestContainer: View {
    var overridesMaintainer = OverridesMaintainer()

    var childView: AnyView {
        if let override = overridesMaintainer.override(for: "childView") {
            return override
        }
        return AnyView(Text("Default View"))
    }

    var body: some View {
        childView
    }
}

final class OverridesMaintainerTests: XCTestCase {
    func testOverrideInjection() {
        var container = TestContainer()
        // Apply override
        container.overridesMaintainer.updateOverride(for: "childView", with: AnyView(Text("Injected View")))

        let description = String(describing: container.childView)
        XCTAssertTrue(description.contains("Injected View"), "The overridden view should be rendered instead of the default.")
    }

    func testOverrideRemoval() {
        let maintainer = OverridesMaintainer()
        maintainer.updateOverride(for: "childView", with: AnyView(Text("Injected")))
        maintainer.removeOverride(for: "childView")
        XCTAssertNil(maintainer.override(for: "childView"))
    }

    func testOverrideReset() {
        let maintainer = OverridesMaintainer()
        maintainer.updateOverride(for: "childView", with: AnyView(Text("Injected")))
        maintainer.resetOverrides()
        XCTAssertTrue(maintainer.overrides.isEmpty)
    }
}
