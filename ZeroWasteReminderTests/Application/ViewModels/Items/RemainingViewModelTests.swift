@testable import ZeroWasteReminder
import XCTest

class RemainingViewModelTests: XCTestCase {
    func test_formattedValue_withNotDefinedState_returnsEmptyString() {
        let sut = RemainingViewModel(.empty)
        XCTAssertEqual(sut.formattedValue, "")
    }

    func test_formattedValue_withExpiredState_returnsExpired() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
            .withExpiration(.date(Date().adding(-1, .day)))

        let sut = RemainingViewModel(item)
        XCTAssertEqual(sut.formattedValue, "expired")
    }

    func test_formattedValue_withAlmostExpiredState_returnsAlmostExpired() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
            .withExpiration(.date(Date()))

        let sut = RemainingViewModel(item)
        XCTAssertEqual(sut.formattedValue, "almost expired")
    }

    func test_formattedValue_withOneDayValidState_returnsOneDay() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
            .withExpiration(.date(Date().adding(1, .day)))

        let sut = RemainingViewModel(item)
        XCTAssertEqual(sut.formattedValue, "1 day")
    }
}
