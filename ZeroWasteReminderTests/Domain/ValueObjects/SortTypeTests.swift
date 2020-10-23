@testable import ZeroWasteReminder
import XCTest

class SortTypeTests: XCTestCase {
    func test_toggle_whenAscending_changesToDescending() {
        var sut: SortType = .ascending
        sut.toggle()
        XCTAssertEqual(sut, .descending)
    }

    func test_toggle_whenDescending_changesToAscending() {
        var sut: SortType = .descending
        sut.toggle()
        XCTAssertEqual(sut, .ascending)
    }

    func test_action_whenAscendingAndWithSortedItems_returnsTrue() {
        let sut: SortType = .ascending
        let item1 = Item(id: .fromUuid(UUID()), name: "First item", listId: .fromUuid(UUID()))
        let item2 = Item(id: .fromUuid(UUID()), name: "Second item", listId: .fromUuid(UUID()))
        XCTAssertTrue(sut.action()(item1, item2))
    }

    func test_action_whenDescendingAndWithSortedItems_returnsFalse() {
        let sut: SortType = .descending
        let item1 = Item(id: .fromUuid(UUID()), name: "First item", listId: .fromUuid(UUID()))
        let item2 = Item(id: .fromUuid(UUID()), name: "Second item", listId: .fromUuid(UUID()))
        XCTAssertFalse(sut.action()(item1, item2))
    }

    func test_action_whenAscendingAndWithUnsortedItems_returnsFalse() {
        let sut: SortType = .ascending
        let item1 = Item(id: .fromUuid(UUID()), name: "Second item", listId: .fromUuid(UUID()))
        let item2 = Item(id: .fromUuid(UUID()), name: "First item", listId: .fromUuid(UUID()))
        XCTAssertFalse(sut.action()(item1, item2))
    }

    func test_action_whenDescendingAndWithUnsortedItems_returnsTrue() {
        let sut: SortType = .descending
        let item1 = Item(id: .fromUuid(UUID()), name: "Second item", listId: .fromUuid(UUID()))
        let item2 = Item(id: .fromUuid(UUID()), name: "First item", listId: .fromUuid(UUID()))
        XCTAssertTrue(sut.action()(item1, item2))
    }
}
