@testable import ZeroWasteReminder
import XCTest
import Combine

class AlwaysEligibleAccountServiceTests: XCTestCase {
    private var sut: AccountService!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.sut = AlwaysEligibleAccountService()
        self.subscriptions = []
    }

    override func tearDown() {
        self.sut = nil
        self.subscriptions = nil
        super.tearDown()
    }

    func test_isUserEligible_sendsTrue() {
        let expectation = self.expectation(description: "")

        var isUserEligible: Bool?

        sut.isUserEligible
            .sink {
                isUserEligible = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(isUserEligible == true)
    }
}
