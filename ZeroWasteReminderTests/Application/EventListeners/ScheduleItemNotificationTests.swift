@testable import ZeroWasteReminder
import XCTest
import Combine

class ScheduleItemNotificationTests: XCTestCase {
    private var sut: ScheduleItemNotification!
    private var notificationScheduler: ItemNotificationSchedulerMock!
    private var eventDispatcher: EventDispatcher!

    override func setUp() {
        super.setUp()
        self.notificationScheduler = ItemNotificationSchedulerMock()
        self.eventDispatcher = EventDispatcher()
        self.sut = ScheduleItemNotification(notificationScheduler, eventDispatcher)
    }

    override func tearDown() {
        self.sut = nil
        self.eventDispatcher = nil
        self.notificationScheduler = nil
        super.tearDown()
    }

    func test_whenDispatchedItemAddedEvent_scheduleNotificationIsCalled() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        let expectation = self.expectation(description: "")

        var sentItems = [Item]()

        notificationScheduler.scheduleNotificationCalled = {
            sentItems = $0
            expectation.fulfill()
        }

        eventDispatcher.dispatch(ItemAdded(item))

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sentItems.count, 1)
        XCTAssertEqual(sentItems[0], item)
    }

    func test_whenDispatchedItemUpdatedEvent_withAlertOption_scheduleNotificationIsCalled() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
            .withExpiration(.date(Date().adding(1, .month)))
            .withAlertOption(.daysBefore(1))

        let expectation = self.expectation(description: "")

        var sentItems = [Item]()

        notificationScheduler.scheduleNotificationCalled = {
            sentItems = $0
            expectation.fulfill()
        }

        eventDispatcher.dispatch(ItemUpdated(item))

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sentItems.count, 1)
        XCTAssertEqual(sentItems[0], item)
    }

    func test_whenDispatchedItemUpdatedEvent_withNoneAlertOption_removeScheduledNotificationIsCalled() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty).withAlertOption(.none)
        let expectation = self.expectation(description: "")

        var sentItems = [Item]()

        notificationScheduler.removeScheduledNotificationCalled = {
            sentItems = $0
            expectation.fulfill()
        }

        eventDispatcher.dispatch(ItemUpdated(item))

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sentItems.count, 1)
        XCTAssertEqual(sentItems[0], item)
    }

    func test_whenDispatchedItemsRemovedEvent_removeScheduledNotificationIsCalled() {
        let item1 = Item(id: .fromUuid(UUID()), name: "The first item", listId: .empty)
        let item2 = Item(id: .fromUuid(UUID()), name: "The second item", listId: .empty)
        let expectation = self.expectation(description: "")

        var sentItems = [Item]()

        notificationScheduler.removeScheduledNotificationCalled = {
            sentItems = $0
            expectation.fulfill()
        }

        eventDispatcher.dispatch(ItemsRemoved([item1, item2]))

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sentItems.count, 2)
        XCTAssertTrue(sentItems.contains(item1))
        XCTAssertTrue(sentItems.contains(item2))
    }

    func test_whenDispatchedListRemovedEvent_removeScheduledNotificationForItemsIsCalled() {
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let expectation = self.expectation(description: "")

        var sentList: List?

        notificationScheduler.removeScheduledNotificationForItemsCalled = {
            sentList = $0
            expectation.fulfill()
        }

        eventDispatcher.dispatch(ListRemoved(list))

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(list, sentList)
    }
}

private extension ScheduleItemNotificationTests {
    class ItemNotificationSchedulerMock: ItemNotificationsScheduler {
        var scheduleNotificationCalled: (([Item]) -> Void)?
        var removeScheduledNotificationCalled: (([Item]) -> Void)?
        var removeScheduledNotificationForItemsCalled: ((List) -> Void)?

        func scheduleNotification(for items: [Item]) {
            scheduleNotificationCalled?(items)
        }

        func removeScheduledNotification(for items: [Item]) {
            removeScheduledNotificationCalled?(items)
        }

        func removeScheduledNotificationForItems(in list: List) {
            removeScheduledNotificationForItemsCalled?(list)
        }
    }
}
