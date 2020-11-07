@testable import ZeroWasteReminder
import XCTest
import Combine

class SearchBarViewModelTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        super.tearDown()
    }

    func test_init_searchTermIsEmpty() {
        let viewModel = SearchBarViewModel()
        XCTAssertEqual(viewModel.searchTerm, "")
    }

    func test_dismissTapped_sendsDismissTap() {
        let expectation = self.expectation(description: "")
        let viewModel = SearchBarViewModel()

        viewModel.dismissTap
            .sink { expectation.fulfill() }
            .store(in: &subscriptions)

        viewModel.dismissTapped()

        wait(for: [expectation], timeout: 0.1)
    }
}
