@testable import ZeroWasteReminder
import XCTest
import Combine

class ExpirationDateViewModelTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        super.tearDown()
    }

    func test_formattedDate_sendsDateInProperFormat() {
        let expectation = self.expectation(description: "")
        let date = Date()
        let sut = ExpirationDateViewModel(initialDate: date)

        var formattedDate: String?
        sut.formattedDate
            .sink {
                formattedDate = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(formattedDate, DateFormatter.fullDate.string(from: date))
    }

    func test_toggleDatePicker_calledOnce_sendsIsDatePickerVisibleSetToTrue() {
        let expectation = self.expectation(description: "")
        let sut = ExpirationDateViewModel(initialDate: Date())

        sut.isDatePickerVisible
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.toggleDatePicker()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_toggleDatePicker_calledTwice_sendsIsDatePickerVisibleSetToFalse() {
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = 2

        let sut = ExpirationDateViewModel(initialDate: Date())

        sut.isDatePickerVisible
            .filter { !$0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.toggleDatePicker()
        sut.toggleDatePicker()

        wait(for: [expectation], timeout: 0.1)
    }
}
