import XCTest
@testable import SwiftMacrosKit

final class SwiftMacrosKitGeneralTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(SwiftMacrosKit.version, "1.0.0")
    }
}
