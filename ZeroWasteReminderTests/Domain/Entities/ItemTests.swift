@testable import ZeroWasteReminder
import XCTest

class ItemTests: XCTestCase {
    func test_empty_returnsEmptyItem() {
        let item: Item = .empty
        XCTAssertEqual(item, .init(id: .empty, name: "", listId: .empty))
    }

    func test_withName_returnsItemWithUpdatedName() {
        let item: Item = .empty
        let updatedItem: Item = item.withName("New name")
        XCTAssertEqual(updatedItem.name, "New name")
    }

    func test_withExpiration_returnsItemWithUpdatedExpiration() {
        let item: Item = .empty
        let expiration: Expiration = .date(Date())

        let updatedItem: Item = item.withExpiration(expiration)
        XCTAssertEqual(updatedItem.expiration, expiration)
    }

    func test_withExpirationDate_withDateSet_returnsItemWithUpdatedExpiration() {
        let item: Item = .empty
        let expirationDate: Date? = Date()

        let updatedItem: Item = item.withExpirationDate(expirationDate)

        XCTAssertEqual(updatedItem.expiration, .fromDate(expirationDate))
    }

    func test_withExpirationDate_withDateSetToNil_returnsItemWithUpdatedExpiration() {
        let item: Item = .empty
        let updatedItem: Item = item.withExpirationDate(nil)
        XCTAssertEqual(updatedItem.expiration, .none)
    }

    func test_withNotes_returnsItemWithUpdatedNotes() {
        let item: Item = .empty
        let updatedItem: Item = item.withNotes("This is a note.")
        XCTAssertEqual(updatedItem.notes, "This is a note.")
    }

    func test_withListId_returnsItemWithUpdatedListId() {
        let item: Item = .empty
        let listId: Id<List> = .fromUuid(UUID())

        let updatedItem: Item = item.withListId(listId)

        XCTAssertEqual(updatedItem.listId, listId)
    }

    func test_withAlertOption_withExpirationNotSet_returnsItemWithUpdatedAlertOptionToNone() {
        let item: Item = .empty
        let updatedItem: Item = item.withAlertOption(.daysBefore(3))
        XCTAssertEqual(updatedItem.alertOption, .none)
    }

    func test_withAlertOption_withExpirationSet_returnsItemWithUpdatedAlertOption() {
        let item: Item = Item.empty.withExpiration(.date(Date().adding(1, .month)))
        let updatedItem: Item = item.withAlertOption(.daysBefore(3))
        XCTAssertEqual(updatedItem.alertOption, .daysBefore(3))
    }

    func test_equals_withAllFieldsTheSame_returnsTrue() {
        let itemId: Id<Item> = .fromUuid(UUID())
        let listId: Id<List> = .fromUuid(UUID())
        let date: Date = Date().adding(1, .month)

        let item1 = Item(id: itemId, name: "The item", listId: listId)
            .withNotes("This is a note.")
            .withExpiration(.fromDate(date))
            .withAlertOption(.daysBefore(1))

        let item2 = Item(id: itemId, name: "The item", listId: listId)
            .withNotes("This is a note.")
            .withExpiration(.fromDate(date))
            .withAlertOption(.daysBefore(1))

        XCTAssertEqual(item1, item2)
    }

    func test_equals_withDifferentId_returnsFalse() {
        let listId: Id<List> = .fromUuid(UUID())

        let item1 = Item(id: .fromUuid(UUID()), name: "The item", listId: listId)
        let item2 = Item(id: .fromUuid(UUID()), name: "The item", listId: listId)

        XCTAssertNotEqual(item1, item2)
    }

    func test_equals_withDifferentListId_returnsFalse() {
        let itemId: Id<Item> = .fromUuid(UUID())

        let item1 = Item(id: itemId, name: "The item", listId: .fromUuid(UUID()))
        let item2 = Item(id: itemId, name: "The item", listId: .fromUuid(UUID()))

        XCTAssertNotEqual(item1, item2)
    }

    func test_equals_withDifferentExpiration_returnsFalse() {
        let itemId: Id<Item> = .fromUuid(UUID())
        let listId: Id<List> = .fromUuid(UUID())

        let item1 = Item(id: itemId, name: "The item", listId: listId)
        let item2 = Item(id: itemId, name: "The item", listId: listId)
            .withExpiration(.fromDate(Date()))

        XCTAssertNotEqual(item1, item2)
    }

    func test_equals_withDifferentAlertOption_returnsFalse() {
        let itemId: Id<Item> = .fromUuid(UUID())
        let listId: Id<List> = .fromUuid(UUID())
        let date: Date = Date().adding(1, .month)

        let item1 = Item(id: itemId, name: "The item", listId: listId)
            .withExpiration(.fromDate(date))

        let item2 = Item(id: itemId, name: "The item", listId: listId)
            .withExpiration(.fromDate(date))
            .withAlertOption(.daysBefore(1))

        XCTAssertNotEqual(item1, item2)
    }

    func test_equals_withDifferentNote_returnsFalse() {
        let itemId: Id<Item> = .fromUuid(UUID())
        let listId: Id<List> = .fromUuid(UUID())

        let item1 = Item(id: itemId, name: "The item", listId: listId)
        let item2 = Item(id: itemId, name: "The item", listId: listId)
            .withNotes("The note")

        XCTAssertNotEqual(item1, item2)
    }
}
