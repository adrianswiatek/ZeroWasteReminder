@testable import ZeroWasteReminder
import XCTest
import Combine

class AlertViewModelTests: XCTestCase {
    private var eventDispatcher: EventDispatcher!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.eventDispatcher = EventDispatcher()
        self.subscriptions = []
    }

    override func tearDown() {
        self.eventDispatcher = nil
        self.subscriptions = nil
        super.tearDown()
    }

    func test_numberOfCells_whenSelectedCellIsNotDate_returnsNine() {
        let sut = AlertViewModel(selectedOption: .none, eventDispatcher: eventDispatcher)
        sut.selectCell(at: 0)
        XCTAssertEqual(sut.numberOfCells, 9)
    }

    func test_numberOfCells_whenSelectedCellIsDate_returnsTen() {
        let sut = AlertViewModel(selectedOption: .none, eventDispatcher: eventDispatcher)
        sut.selectCell(at: sut.numberOfCells - 1)
        XCTAssertEqual(sut.numberOfCells, 10)
    }

    func test_indexOfCalendarCell_whenSelectedCellIsNotDate_returnsNil() {
        let sut = AlertViewModel(selectedOption: .none, eventDispatcher: eventDispatcher)
        sut.selectCell(at: 0)
        XCTAssertNil(sut.indexOfCalendarCell)
    }

    func test_indexOfCalendarCell_whenSelectedCellIsDate_returnsNine() {
        let sut = AlertViewModel(selectedOption: .none, eventDispatcher: eventDispatcher)
        sut.selectCell(at: sut.numberOfCells - 1)
        XCTAssertEqual(sut.indexOfCalendarCell, 9)
    }

    func test_selectCell_whenNotLast_sendsDismissRequest() {
        let sut = AlertViewModel(selectedOption: .customDate(.init()), eventDispatcher: eventDispatcher)
        let expectation = self.expectation(description: "")

        var sentRequest: AlertViewModel.Request?
        sut.requestSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.selectCell(at: 0)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .dismiss)
    }

    func test_selectCell_whenNotLast_sendsAlertSetEvent() {
        let sut = AlertViewModel(selectedOption: .customDate(.init()), eventDispatcher: eventDispatcher)
        let expectation = self.expectation(description: "")

        var sentEvent: AppEvent?
        eventDispatcher.events
            .sink {
                sentEvent = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.selectCell(at: 0)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(sentEvent is AlertSet)
    }

    func test_selectCell_whenLast_sendsHideCalendarRequest() {
        let sut = AlertViewModel(selectedOption: .none, eventDispatcher: eventDispatcher)
        let expectation = self.expectation(description: "")

        var sentRequest: AlertViewModel.Request?
        sut.requestSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.selectCell(at: sut.numberOfCells - 1)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .showCalendar)
    }

    func test_selectCell_whenCalledTwiceWithDateCell_sendsAlertSetEvent() {
        let sut = AlertViewModel(selectedOption: .customDate(Date()), eventDispatcher: eventDispatcher)
        let expectation = self.expectation(description: "")

        var sentEvent: AppEvent?
        eventDispatcher.events
            .sink {
                sentEvent = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.selectCell(at: sut.numberOfCells - 1)
        sut.selectCell(at: sut.numberOfCells - 2)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(sentEvent is AlertSet)
    }

    func test_selectCell_whenCalledTwiceWithDateCell_sendsDismissRequest() {
        let sut = AlertViewModel(selectedOption: .customDate(Date()), eventDispatcher: eventDispatcher)
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = 2

        var sentRequest: AlertViewModel.Request?
        sut.requestSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.selectCell(at: sut.numberOfCells - 1)
        sut.selectCell(at: sut.numberOfCells - 2)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .dismiss)
    }
}
