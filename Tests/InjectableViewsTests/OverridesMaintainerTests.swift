import XCTest
import SwiftUI
@testable import InjectableViews

final class OverridesMaintainerTests: XCTestCase {
    func testRemoveOverride() {
        let maintainer = OverridesMaintainer()
        maintainer.overrideView(AnyView(Text("A")), for: "key")
        XCTAssertNotNil(maintainer.override(for: "key"))
        maintainer.removeOverride(for: "key")
        XCTAssertNil(maintainer.override(for: "key"))
    }

    func testResetAll() {
        let maintainer = OverridesMaintainer()
        maintainer.overrideView(AnyView(Text("A")), for: "key1")
        maintainer.overrideView(AnyView(Text("B")), for: "key2")
        XCTAssertNotNil(maintainer.override(for: "key1"))
        XCTAssertNotNil(maintainer.override(for: "key2"))
        maintainer.resetAll()
        XCTAssertNil(maintainer.override(for: "key1"))
        XCTAssertNil(maintainer.override(for: "key2"))
    }
}
