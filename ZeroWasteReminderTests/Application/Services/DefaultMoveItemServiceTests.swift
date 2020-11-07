@testable import ZeroWasteReminder
import XCTest
import Combine

class DefaultMoveItemServiceTests: XCTestCase {
    private var sut: DefaultMoveItemService!
    private var listsRepository: ListsRepositoryStub!
    private var itemsWriteRepository: ItemsWriteRepositoryMock!
    private var eventDispatcher: EventDispatcher!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.listsRepository = ListsRepositoryStub()
        self.itemsWriteRepository = ItemsWriteRepositoryMock()
        self.eventDispatcher = EventDispatcher()
        self.sut = DefaultMoveItemService(
            listsRepository: listsRepository,
            itemsWriteRepository: itemsWriteRepository,
            eventDispatcher: eventDispatcher
        )
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        self.sut = nil
        self.eventDispatcher = nil
        self.itemsWriteRepository = nil
        self.listsRepository = nil
        super.tearDown()
    }

    func test_fetchListsForItem_returnsFilteredLists() {
        let list1 = List(id: .fromUuid(UUID()), name: "First list")
        let list2 = List(id: .fromUuid(UUID()), name: "Second list")
        listsRepository.lists = [list1, list2]

        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: list1.id)
        let expectation = self.expectation(description: "")

        var fetchedLists = [List]()

        sut.fetchLists(for: item)
            .sink {
                fetchedLists = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(fetchedLists.count, 1)
        XCTAssertEqual(fetchedLists[0], list2)
    }

    func test_moveItem_moveIsCalledOnItemsWriteRepository() {
        let item = Item(id: .fromUuid(UUID()), name: "The item", listId: .empty)
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let expectation = self.expectation(description: "")

        var sentItem: Item?
        var sentList: List?

        itemsWriteRepository.moveCalled = { item, list in
            sentItem = item
            sentList = list
            expectation.fulfill()
        }

        sut.moveItem(item, to: list)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(item, sentItem)
        XCTAssertEqual(list, sentList)
    }
}

private extension DefaultMoveItemServiceTests {
    class ListsRepositoryStub: ListsRepository {
        var lists = [List]()

        func fetchAll() -> Future<[List], Never> {
            Future { [weak self] in $0(.success(self?.lists ?? [])) }
        }

        func add(_ list: List) {}
        func remove(_ list: List) {}
        func update(_ lists: [List]) {}
    }

    class ItemsWriteRepositoryMock: ItemsWriteRepository {
        var moveCalled: ((Item, List) -> Void)?

        func move(_ item: Item, to list: List) {
            moveCalled?(item, list)
        }

        func add(_ itemToSave: ItemToSave) {}
        func update(_ item: Item) {}
        func remove(_ item: Item) {}
        func remove(_ items: [Item]) {}
    }
}
