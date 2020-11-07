@testable import ZeroWasteReminder
import XCTest
import Combine

class AddItemViewModelTests: XCTestCase {
    private var sut: AddItemViewModel!
    private var itemsWriteRepository: ItemsWriteRepositoryMock!
    private var photosRepository: PhotosRepositoryMock!
    private var fileService: FileService!
    private var statusNotifier: StatusNotifier!
    private var eventDispatcher: EventDispatcher!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.itemsWriteRepository = ItemsWriteRepositoryMock()
        self.photosRepository = PhotosRepositoryMock()
        self.fileService = FileServiceDummy()
        self.statusNotifier = StatusNotifierDummy()
        self.eventDispatcher = EventDispatcher()
        self.sut = AddItemViewModel(
            itemsWriteRepository: itemsWriteRepository,
            photosRepository: photosRepository,
            fileService: fileService,
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
        self.fileService = nil
        self.photosRepository = nil
        self.itemsWriteRepository = nil
        super.tearDown()
    }

    func test_setLoading_withTrue_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.setLoading(true)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_setLoading_withFalse_sendsIsLoadingSetToFalse() {
        let expectation = self.expectation(description: "")

        sut.isLoading
            .filter { !$0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.setLoading(false)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenSentItemAddedEvent_callsUpdateOnPhotosRepository() {
        let expectation = self.expectation(description: "")
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)

        photosRepository.updateCalled = {
            guard $0 == PhotosChangeset(), $1 == item else { return }
            expectation.fulfill()
        }

        eventDispatcher.dispatch(ItemAdded(item))

        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenSentPhotosUpdatedEvent_dismissRequestiIsSent() {
        let expectation = self.expectation(description: "")

        var sentRequest: AddItemViewModel.Request?
        sut.requestSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(PhotosUpdated(.empty))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .dismiss)
    }

    func test_whenSentNoResultOccuredEvent_dismissRequestiIsSent() {
        let expectation = self.expectation(description: "")

        var sentRequest: AddItemViewModel.Request?
        sut.requestSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(NoResultOccured())

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .dismiss)
    }

    func test_whenSentErrorOccuredEvent_showErrorMessageRequestIsSent() {
        let errorMessage = "Error message"
        let expectation = self.expectation(description: "")

        var sentRequest: AddItemViewModel.Request?
        sut.requestSubject
            .sink {
                sentRequest = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        eventDispatcher.dispatch(ErrorOccured(.general(errorMessage)))

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(sentRequest, .showErrorMessage(errorMessage))
    }

    func test_isExpirationDateVisible_withDate_returnsTrue() {
        sut.expirationTypeIndex = ExpirationType.date.index
        XCTAssertTrue(sut.isExpirationDateVisible)
    }

    func test_isExpirationDateVisible_withNotDate_returnsFalse() {
        sut.expirationTypeIndex = ExpirationType.none.index
        XCTAssertFalse(sut.isExpirationDateVisible)

        sut.expirationTypeIndex = ExpirationType.period.index
        XCTAssertFalse(sut.isExpirationDateVisible)
    }

    func test_isExpirationPeriodVisible_withPeriod_returnsTrue() {
        sut.expirationTypeIndex = ExpirationType.period.index
        XCTAssertTrue(sut.isExpirationPeriodVisible)
    }

    func test_isExpirationDateVisible_withNotPeriod_returnsFalse() {
        sut.expirationTypeIndex = ExpirationType.none.index
        XCTAssertFalse(sut.isExpirationPeriodVisible)

        sut.expirationTypeIndex = ExpirationType.date.index
        XCTAssertFalse(sut.isExpirationPeriodVisible)
    }

    func test_isAlertSectionVisible_withNoneExpiration_returnsFalse() {
        let expectation = self.expectation(description: "")

        sut.isAlertSectionVisible
            .dropFirst()
            .filter { !$0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.expirationTypeIndex = ExpirationType.none.index

        wait(for: [expectation], timeout: 0.1)
    }

    func test_isAlertSectionVisible_withDateExpiration_returnsTrue() {
        let expectation = self.expectation(description: "")

        sut.isAlertSectionVisible
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.expirationTypeIndex = ExpirationType.date.index

        wait(for: [expectation], timeout: 0.1)
    }

    func test_isAlertSectionVisible_withPeriodExpiration_returnsTrue() {
        let expectation = self.expectation(description: "")

        sut.isAlertSectionVisible
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.expirationTypeIndex = ExpirationType.period.index

        wait(for: [expectation], timeout: 0.1)
    }

    func test_saveItem_sendsIsLoadingSetToTrue() {
        let expectation = self.expectation(description: "")

        sut.name = "The item"
        sut.set(List(id: .fromUuid(UUID()), name: "The list"))

        sut.isLoading
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.saveItem()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_saveItem_callsAddOnItemsWriteRepository() {
        let expectation = self.expectation(description: "")
        let list = List(id: .fromUuid(UUID()), name: "The list")

        sut.name = "The item"
        sut.set(list)

        itemsWriteRepository.addCalled = {
            guard $0.item.name == "The item", $0.list == list else { return }
            expectation.fulfill()
        }

        sut.saveItem()

        wait(for: [expectation], timeout: 0.1)
    }

    func test_canSaveItem_withNonEmptyNameAndNoneExpiration_returnsTrue() {
        let expectation = self.expectation(description: "")

        sut.canSaveItem
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.name = "The item"

        wait(for: [expectation], timeout: 0.1)
    }

    func test_canSaveItem_withNonEmptyNameAndPeriodExpiration_returnsTrue() {
        let expectation = self.expectation(description: "")

        sut.canSaveItem
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.expirationPeriodViewModel.period = "1"
        sut.expirationTypeIndex = ExpirationType.period.index
        sut.name = "The item"

        wait(for: [expectation], timeout: 0.1)
    }

    func test_canSaveItem_withNonEmptyNameAndDateExpiration_returnsTrue() {
        let expectation = self.expectation(description: "")

        sut.canSaveItem
            .filter { $0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        sut.expirationTypeIndex = ExpirationType.date.index
        sut.name = "The item"

        wait(for: [expectation], timeout: 0.1)
    }
}

private extension AddItemViewModelTests {
    class ItemsWriteRepositoryMock: ItemsWriteRepository {
        var addCalled: ((ItemToSave) -> Void)?

        func add(_ itemToSave: ItemToSave) {
            addCalled?(itemToSave)
        }

        func update(_ item: Item) {}
        func move(_ item: Item, to list: List) {}
        func remove(_ item: Item) {}
        func remove(_ items: [Item]) {}
    }

    class PhotosRepositoryMock: PhotosRepository {
        var updateCalled: ((PhotosChangeset, Item) -> Void)?

        func fetchThumbnail(with id: Id<Photo>) -> Future<Photo?, Never> {
            Future { $0(.success(nil)) }
        }

        func fetchThumbnails(for item: Item) -> Future<[Photo], Never> {
            Future { $0(.success([])) }
        }

        func fetchFullSize(with id: Id<Photo>) -> Future<Photo?, Never> {
            Future { $0(.success(nil)) }
        }

        func update(_ photosChangeset: PhotosChangeset, for item: Item) {
            updateCalled?(photosChangeset, item)
        }
    }

    class FileServiceDummy: FileService {
        func trySaveData(_ data: Data) -> URL? {
            nil
        }

        func saveTemporaryImage(_ image: UIImage) -> Future<URL, FileServiceError> {
            Future { $0(.success(URL(string: "")!)) }
        }

        func removeTemporaryItems() -> Future<Void, FileServiceError> {
            Future { $0(.success(())) }
        }

        func removeItem(at url: URL) -> Future<Void, FileServiceError> {
            Future { $0(.success(())) }
        }
    }

    class StatusNotifierDummy: StatusNotifier {
        var remoteStatus: AnyPublisher<RemoteStatus, Never> {
            Just(.connected).eraseToAnyPublisher()
        }

        var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> {
            Just(.authorized).eraseToAnyPublisher()
        }
    }
}
