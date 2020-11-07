@testable import ZeroWasteReminder
import XCTest

class AlertDateCellViewModelTests: XCTestCase {
    func test_fromAlertOption_withCustomDate_initializesWithDateSet() {
        let date: Date = .init()
        let viewModel: AlertDateCellViewModel = .fromAlertOption(.customDate(date))
        XCTAssertEqual(viewModel.date, date)
    }

    func test_fromAlertOption_withoutCustomDate_initializedWithoutDateSet() {
        let viewModel: AlertDateCellViewModel = .fromAlertOption(.none)
        XCTAssertEqual(viewModel.date, nil)
    }
}
