@testable import ZeroWasteReminder
import XCTest
import Combine

class ExpirationPeriodViewModelTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        super.tearDown()
    }

    func test_canUpdate_withEmptyPeriodText_returnsTrue() {
        let sut = ExpirationPeriodViewModel(initialPeriodType: .day)
        XCTAssertTrue(sut.canUpdate(period: ""))
    }

    func test_canUpdate_withInvalidPeriodText_returnsFalse() {
        let sut = ExpirationPeriodViewModel(initialPeriodType: .day)
        XCTAssertFalse(sut.canUpdate(period: "-1"))
        XCTAssertFalse(sut.canUpdate(period: "0"))
        XCTAssertFalse(sut.canUpdate(period: "1234"))
    }

    func test_periodType_returnsCurrentPeriodType() {
        let expectation = self.expectation(description: "")
        let sut = ExpirationPeriodViewModel(initialPeriodType: .day)

        sut.periodType
            .filter { $0 == .day }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_expiration_withPeriod_isNotEqualToNone() {
        let sut = ExpirationPeriodViewModel(initialPeriodType: .day)
        sut.period = "1"
        XCTAssertNotEqual(sut.expiration, .none)
    }
}
