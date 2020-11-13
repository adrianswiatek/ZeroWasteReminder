@testable import ZeroWasteReminder
import XCTest
import Combine

class SearchViewModelTests: XCTestCase {
    private var sut: SearchViewModel!
    private var listsRepository: ListsRepositoryMock!
    private var itemsRepository: ItemsReadRepositoryMock!
    private var statusNotifier: StatusNotifier!
    private var updateListsDate: UpdateListsDate!
    private var eventDispatcher: EventDispatcher!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.listsRepository = ListsRepositoryMock()
        self.itemsRepository = ItemsReadRepositoryMock()
        self.statusNotifier = StatusNotifierDummy()
        self.eventDispatcher = EventDispatcher()
        self.updateListsDate = UpdateListsDate(listsRepository, eventDispatcher)
        self.sut = SearchViewModel(
            listsRepository: listsRepository,
            itemsRepository: itemsRepository,
            statusNotifier: statusNotifier,
            updateListsDate: updateListsDate,
            eventDispatcher: eventDispatcher
        )
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        self.sut = nil
        self.updateListsDate = nil
        self.eventDispatcher = nil
        self.itemsRepository = nil
        self.listsRepository = nil
        super.tearDown()
    }

    func test_fetchLists_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.fetchLists()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_fetchLists_whenReceivedLists_sendsIsLoadingSetToFalse() {
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = 3

        var isLoading: Bool?
        sut.isLoading
            .sink {
                isLoading = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.fetchLists()

        wait(for: [expectation], timeout: 0.1)
        XCTAssert(isLoading == false)
    }

    func test_fetchLists_callsFetchListsOnMoveItemService() {
        let expectation = self.expectation(description: "")

        listsRepository.fetchAllCalled = {
            expectation.fulfill()
        }

        sut.fetchLists()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_searchTerm_setToText_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.searchBarViewModel.searchTerm = "Test"

        wait(for: [expectation], timeout: 0.55)
    }

    func test_searchTerm_callsFetchBySearchTermOnItemsRepository() {
        let expectation = self.expectation(description: "")
        let searchTerm = "Test"

        itemsRepository.fetchBySearchTermCalled = {
            guard $0 == searchTerm else { return }
            expectation.fulfill()
        }

        sut.searchBarViewModel.searchTerm = searchTerm

        wait(for: [expectation], timeout: 0.55)
    }

    func test_whenSentErrorOccuredEvent_showErrorMessageRequestIsSent() {
        let errorMessage = "Error message"
        let expectation = self.expectation(description: "")

        var sentRequest: SearchViewModel.Request?
        sut.requestsSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ErrorOccured(.general(errorMessage)))

        wait(for: [expectation], timeout: 0.55)
        XCTAssertEqual(sentRequest, .showErrorMessage(errorMessage))
    }

    func test_whenSentItemsRemovedEvent_itemsPropertyIsUpdated() {
        let expectation = self.expectation(description: "")
        expectation.assertForOverFulfill = false

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        sut.items += .just(SearchItem(item: item))

        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ItemsRemoved(item))

        wait(for: [expectation], timeout: 0.55)
        XCTAssertEqual(sut.items.count, 0)
    }

    func test_whenSentItemUpdatedEvent_itemsPropertyIsUpdated() {
        let expectation = self.expectation(description: "")
        expectation.assertForOverFulfill = false

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        sut.items += .just(SearchItem(item: item))

        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ItemUpdated(item.withName("The item 2")))

        wait(for: [expectation], timeout: 0.55)
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items[0].item.name, "The item 2")
    }

    func test_whenSentItemMovedEvent_itemsPropertyIsUpdated() {
        let expectation = self.expectation(description: "")
        expectation.assertForOverFulfill = false

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        sut.items += .just(SearchItem(item: item))

        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ItemMoved(item, to: List(id: .empty, name: "")))

        wait(for: [expectation], timeout: 0.55)
        XCTAssertEqual(sut.items.count, 0)
    }

    func test_openItem_sendsNavigateToItemRequest() {
        let expectation = self.expectation(description: "")

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        sut.items += .just(SearchItem(item: item))

        sut.requestsSubject
            .sink {
                guard case .navigateToItem = $0 else { return }
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.openItem(at: 0)

        wait(for: [expectation], timeout: 0.1)
    }
}

private extension SearchViewModelTests {
    class ListsRepositoryMock: ListsRepository {
        var fetchAllCalled: (() -> Void)?

        func fetchAll() -> Future<[List], Never> {
            fetchAllCalled?()
            return Future { $0(.success([])) }
        }

        func add(_ list: List) {}
        func remove(_ list: List) {}
        func update(_ lists: [List]) {}
    }

    class ItemsReadRepositoryMock: ItemsReadRepository {
        var fetchBySearchTermCalled: ((String) -> Void)?

        func fetchAll(from list: List) -> Future<[Item], Never> {
            Future { $0(.success([])) }
        }

        func fetch(by id: Id<Item>) -> Future<Item?, Never> {
            Future { $0(.success(nil)) }
        }

        func fetch(by searchTerm: String) -> Future<[Item], Never> {
            fetchBySearchTermCalled?(searchTerm)
            return Future { $0(.success([])) }
        }
    }
}
