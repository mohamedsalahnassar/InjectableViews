import XCTest
import SwiftUI
@testable import InjectableViews

final class OverridesMaintainerConcurrencyTests: XCTestCase {
    func testConcurrentOverrideUpdates() async {
        let maintainer = OverridesMaintainer()
        let iterations = 100
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    await maintainer.updateOverride(for: "\(i)", with: AnyView(Text("\(i)")))
                }
            }
        }
        for i in 0..<iterations {
            let value = await maintainer.override(for: "\(i)")
            XCTAssertNotNil(value)
        }
    }
}
