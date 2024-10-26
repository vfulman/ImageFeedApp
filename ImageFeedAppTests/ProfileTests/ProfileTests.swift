@testable import ImageFeedApp
import XCTest

final class ProfileTests: XCTestCase {
    func testProfileLogout() {
        let presenter = ProfilePresenterSpy()
        XCTAssertNotNil(presenter.profile)
        presenter.logout()
        XCTAssertNil(presenter.profile)
    }
}
