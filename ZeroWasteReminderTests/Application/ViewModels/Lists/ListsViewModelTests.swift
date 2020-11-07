@testable import ZeroWasteReminder
import XCTest
import Combine

class ListViewModelTests: XCTestCase {
    private var sut: ListsViewModel!
    private var listsRepository: ListsRepositoryMock!
    private var statusNotifier: StatusNotifier!
    private var eventDispatcher: EventDispatcher!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.listsRepository = ListsRepositoryMock()
        self.statusNotifier = StatusNotifierDummy()
        self.eventDispatcher = EventDispatcher()
        self.sut = ListsViewModel(
            listsRepository: listsRepository,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        self.sut = nil
        self.eventDispatcher = nil
        self.statusNotifier = nil
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
        expectation.expectedFulfillmentCount = 2

        var isLoading: Bool?
        sut.isLoading
            .dropFirst()
            .sink {
                isLoading = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        sut.fetchLists()

        wait(for: [expectation], timeout: 0.1)
        XCTAssert(isLoading == false)
    }

    func test_addList_callsAddOnListsRepository() {
        let expectation = self.expectation(description: "")
        let listName = "The list"

        listsRepository.addCalled = {
            guard $0.name == listName else { return }
            expectation.fulfill()
        }

        sut.addList(withName: listName)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_addList_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.addList(withName: "The list")

        wait(for: [expectation], timeout: 0.1)
    }

    func test_updateList_callsUpdateOnListsRepository() {
        let expectation = self.expectation(description: "")
        let list = List(id: .fromUuid(UUID()), name: "The list")

        listsRepository.updateCalled = {
            guard $0.count == 1, $0.first == list else { return }
            expectation.fulfill()
        }

        sut.updateList(list)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_updateList_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.updateList(List(id: .fromUuid(UUID()), name: "The list"))

        wait(for: [expectation], timeout: 0.1)
    }

    func test_removeList_callsRemoveOnListsRepository() {
        let expectation = self.expectation(description: "")
        let list = List(id: .fromUuid(UUID()), name: "The list")

        listsRepository.removeCalled = {
            guard $0 == list else { return }
            expectation.fulfill()
        }

        sut.removeList(list)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_removeList_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.removeList(List(id: .fromUuid(UUID()), name: "The list"))

        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenSentErrorOccuredEvent_showErrorMessageRequestIsSent() {
        let errorMessage = "Error message"
        let expectation = self.expectation(description: "")

        var sentRequest: ListsViewModel.Request?
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

    func test_whenSentListAddedEvent_listsPropertyIsUpdated() {
        let expectation = self.expectation(description: "")
        let list = List(id: .fromUuid(UUID()), name: "The list")

        sut.$lists
            .dropFirst(1)
            .filter { $0.contains(list) }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ListAdded(list))

        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenSentListRemovedEvent_listsPropertyIsUpdated() {
        let expectation = self.expectation(description: "")
        let list = List(id: .fromUuid(UUID()), name: "The list")
        eventDispatcher.dispatch(ListAdded(list))

        sut.$lists
            .dropFirst(2)
            .filter { !$0.contains(list) }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ListRemoved(list))

        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenSentListsUpdatedEvent_listsPropertyIsUpdated() {
        let expectation = self.expectation(description: "")
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let updatedList = list.withName("Updated list")
        eventDispatcher.dispatch(ListAdded(list))

        sut.$lists
            .dropFirst(2)
            .filter { $0.contains(updatedList) }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ListsUpdated(.just(updatedList)))

        wait(for: [expectation], timeout: 0.1)
    }
}

private extension ListViewModelTests {
    class ListsRepositoryMock: ListsRepository {
        var addCalled: ((List) -> Void)?
        var removeCalled: ((List) -> Void)?
        var updateCalled: (([List]) -> Void)?

        func fetchAll() -> Future<[List], Never> {
            Future { $0(.success([])) }
        }

        func add(_ list: List) {
            addCalled?(list)
        }

        func remove(_ list: List) {
            removeCalled?(list)
        }

        func update(_ lists: [List]) {
            updateCalled?(lists)
        }
    }

    class StatusNotifierDummy: StatusNotifier {
        var remoteStatus: AnyPublisher<RemoteStatus, Never> =
            Just(.connected).eraseToAnyPublisher()

        var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> =
            Just(.authorized).eraseToAnyPublisher()
    }
}
