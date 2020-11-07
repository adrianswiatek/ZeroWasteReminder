@testable import ZeroWasteReminder
import XCTest
import Combine

class ItemsFilterViewModelTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        super.tearDown()
    }

    func test_toggleItem_updatesIndexToScroll() {
        let sut = ItemsFilterViewModel()
        sut.toggleItem(at: 1)
        XCTAssertEqual(sut.indexToScroll, 1)
    }

    func test_toggleItem_updatesIsfilterActive() {
        let sut = ItemsFilterViewModel()
        sut.toggleItem(at: 1)
        XCTAssertTrue(sut.isFilterActive)
    }

    func test_toggleItem_calledTwice_updatesIsFilterActive() {
        let sut = ItemsFilterViewModel()

        sut.toggleItem(at: 1)
        sut.toggleItem(at: 1)

        XCTAssertFalse(sut.isFilterActive)
    }

    func test_toggleItem_updatedsNumberOfSelectedCells() {
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = 4

        let sut = ItemsFilterViewModel()
        sut.numberOfSelectedCells
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.toggleItem(at: 0)
        sut.toggleItem(at: 1)
        sut.toggleItem(at: 2)
        sut.toggleItem(at: 3)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_deselectAll_updatesIsFilterActive() {
        let sut = ItemsFilterViewModel()

        sut.toggleItem(at: 0)
        sut.toggleItem(at: 1)
        sut.toggleItem(at: 2)

        sut.deselectAll()

        XCTAssertFalse(sut.isFilterActive)
    }

    func test_deselectAll_updatesNumberOfSelectedCells() {
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = 5

        let sut = ItemsFilterViewModel()

        var numberOfSelectedCells: Int?
        sut.numberOfSelectedCells
            .dropFirst()
            .sink {
                numberOfSelectedCells = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.toggleItem(at: 0)
        sut.toggleItem(at: 1)
        sut.toggleItem(at: 2)
        sut.toggleItem(at: 3)

        sut.deselectAll()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(numberOfSelectedCells, 0)
    }
}
