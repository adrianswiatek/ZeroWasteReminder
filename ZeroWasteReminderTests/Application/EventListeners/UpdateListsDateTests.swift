@testable import ZeroWasteReminder
import XCTest
import Combine

class UpdateListsDateTests: XCTestCase {
    private var eventDispatcher: EventDispatcher!

    override func setUp() {
        super.setUp()
        self.eventDispatcher = EventDispatcher()
    }

    override func tearDown() {
        self.eventDispatcher = nil
        super.tearDown()
    }

    func test_whenDispatchedItemAddedEvent_updateIsCalledOnItemsRepository() {
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let listsRepository = ListsRepositoryMock()
        let expectation = self.expectation(description: "")

        var updatedLists = [List]()
        listsRepository.updateListsCalled = {
            updatedLists = $0
            expectation.fulfill()
        }

        let sut = UpdateListsDate(listsRepository, eventDispatcher)
        sut.listen(in: list)

        eventDispatcher.dispatch(ItemAdded(.empty))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(updatedLists.count, 1)
        XCTAssertEqual(updatedLists[0].id, list.id)
        XCTAssertNotEqual(updatedLists[0].updateDate, list.updateDate)
    }

    func test_whenDispatchedItemUpdatedEvent_updateIsCalledOnItemsRepository() {
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let listsRepository = ListsRepositoryMock()
        let expectation = self.expectation(description: "")

        var updatedLists = [List]()

        listsRepository.updateListsCalled = {
            updatedLists = $0
            expectation.fulfill()
        }

        let sut = UpdateListsDate(listsRepository, eventDispatcher)
        sut.listen(in: list)

        eventDispatcher.dispatch(ItemUpdated(.empty))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(updatedLists.count, 1)
        XCTAssertEqual(updatedLists[0].id, list.id)
        XCTAssertNotEqual(updatedLists[0].updateDate, list.updateDate)
    }

    func test_whenDispatchedItemRemovedEvent_updateIsCalledOnItemsRepository() {
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let listsRepository = ListsRepositoryMock()
        let expectation = self.expectation(description: "")

        var updatedLists = [List]()
        listsRepository.updateListsCalled = {
            updatedLists = $0
            expectation.fulfill()
        }

        let sut = UpdateListsDate(listsRepository, eventDispatcher)
        sut.listen(in: list)

        eventDispatcher.dispatch(ItemsRemoved(.just(.empty)))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(updatedLists.count, 1)
        XCTAssertEqual(updatedLists[0].id, list.id)
    }

    func test_whenDispatchedItemMovedEvent_udpateIsCalledOnItemsRepository() {
        let list1 = List(id: .fromUuid(UUID()), name: "The list 1")
        let list2 = List(id: .fromUuid(UUID()), name: "The list 2")
        let listsRepository = ListsRepositoryMock()
        let expectation = self.expectation(description: "")

        var updatedLists = [List]()
        listsRepository.updateListsCalled = {
            updatedLists = $0
            expectation.fulfill()
        }

        let sut = UpdateListsDate(listsRepository, eventDispatcher)
        sut.listen(in: list1)

        eventDispatcher.dispatch(ItemMoved(.empty, to: list2))

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(updatedLists.count, 2)

        XCTAssertEqual(updatedLists[0].id, list1.id)
        XCTAssertEqual(updatedLists[1].id, list2.id)

        XCTAssertNotEqual(updatedLists[0].updateDate, list1.updateDate)
        XCTAssertNotEqual(updatedLists[1].updateDate, list2.updateDate)
    }
}

private extension UpdateListsDateTests {
    class ListsRepositoryMock: ListsRepository {
        var updateListsCalled: (([List]) -> Void)?

        func fetchAll() -> Future<[List], Never> {
            Future { $0(.success([])) }
        }

        func update(_ lists: [List]) {
            updateListsCalled?(lists)
        }

        func add(_ list: List) {}
        func remove(_ list: List) {}
    }
}
