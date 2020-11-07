@testable import ZeroWasteReminder
import XCTest
import Combine

class MoveItemViewModelTests: XCTestCase {
    private var sut: MoveItemViewModel!
    private var moveItemService: MoveItemServiceMock!
    private var statusNotifier: StatusNotifier!
    private var eventDispatcher: EventDispatcher!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.moveItemService = MoveItemServiceMock()
        self.statusNotifier = StatusNotifierDummy()
        self.eventDispatcher = EventDispatcher()
        self.subscriptions = []
        self.sut = MoveItemViewModel(
            moveItemService: moveItemService,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
    }

    override func tearDown() {
        self.sut = nil
        self.subscriptions = nil
        self.eventDispatcher = nil
        self.statusNotifier = nil
        self.moveItemService = nil
        super.tearDown()
    }

    func test_whenSentItemMovedEvent_dismissRequestiIsSent() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let expectation = self.expectation(description: "")

        var sentRequest: MoveItemViewModel.Request?
        sut.requestsSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ItemMoved(item, to: list))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .dismiss)
    }

    func test_whenSentErrorOccuredEvent_showErrorMessageRequestIsSent() {
        let errorMessage = "Error message"
        let expectation = self.expectation(description: "")

        var sentRequest: MoveItemViewModel.Request?
        sut.requestsSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ErrorOccured(.general(errorMessage)))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .showErrorMessage(errorMessage))
    }

    func test_fetchLists_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.set(.empty)

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

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        sut.set(item)

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
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)

        sut.set(item)

        moveItemService.fetchListsCalled = {
            guard $0 == item else { return }
            expectation.fulfill()
        }

        sut.fetchLists()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_setItem_setsItemName() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        sut.set(item)
        XCTAssertEqual(sut.itemName, item.name)
    }

    func test_moveItem_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.set(.empty)
        sut.selectList(List(id: .empty, name: ""))

        sut.isLoading
            .filter { $0 }
            .sink {_ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.moveItem()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_moveItem_callsMoveItemOnMoveItemService() {
        let expectation = self.expectation(description: "")

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        let list = List(id: .fromUuid(UUID()), name: "The list")

        sut.set(item)
        sut.selectList(list)

        moveItemService.moveItemCalled = {
            guard $0 == item, $1 == list else { return }
            expectation.fulfill()
        }

        sut.moveItem()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_selectList_sendsCanMoveItemToTrue() {
        let expectation = self.expectation(description: "")

        sut.canMoveItem
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.selectList(List(id: .empty, name: ""))

        wait(for: [expectation], timeout: 0.1)
    }
}

private extension MoveItemViewModelTests {
    class MoveItemServiceMock: MoveItemService {
        var fetchListsCalled: ((Item) -> Void)?
        var moveItemCalled: ((Item, List) -> Void)?

        func fetchLists(for item: Item) -> AnyPublisher<[List], Never> {
            fetchListsCalled?(item)
            return Just([]).eraseToAnyPublisher()
        }

        func moveItem(_ item: Item, to list: List) {
            moveItemCalled?(item, list)
        }
    }

    class StatusNotifierDummy: StatusNotifier {
        var remoteStatus: AnyPublisher<RemoteStatus, Never> =
            Just(.connected).eraseToAnyPublisher()

        var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> =
            Just(.authorized).eraseToAnyPublisher()
    }
}
