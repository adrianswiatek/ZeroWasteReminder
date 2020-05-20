import CloudKit
import Combine

public final class CloudKitItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let database: CKDatabase
    private let subscriptionService: CloudKitSubscriptionService
    private let mapper: CloudKitMapper
    private let notificationCenter: NotificationCenter

    private var subscriptions: Set<AnyCancellable>

    public init(
        container: CKContainer,
        subscriptionService: CloudKitSubscriptionService,
        mapper: CloudKitMapper,
        notificationCenter: NotificationCenter
    ) {
        self.database = container.privateCloudDatabase
        self.subscriptionService = subscriptionService
        self.mapper = mapper
        self.notificationCenter = notificationCenter

        self.itemsSubject = .init([])
        self.subscriptions = []

        self.registerSubscriptionIfNeeded()
        self.registerNotification()
    }

    public func add(_ item: Item) -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self = self, let record = self.mapper.map(item).toRecord() else { return }

            let operation = CKModifyRecordsOperation(recordsToSave: [record])
            operation.modifyRecordsCompletionBlock = { records, _, error in
                assert(error == nil, error!.localizedDescription)
                guard let record = records?.first, let item = self.mapper.map(record).toItem() else { return }

                self.itemsSubject.value = self.itemsSubject.value + [item]
            }
            operation.completionBlock = {
                DispatchQueue.main.async { promise(.success(())) }
            }

            self.database.add(operation)
        }
    }

    public func refresh() -> Future<Void, Never> {
        Future { [weak self] promise in
            var result = [CKRecord]()

            let operation = CKQueryOperation(query: .init(recordType: "Item", predicate: .init(value: true)))
            operation.recordFetchedBlock = { result.append($0) }
            operation.queryCompletionBlock = { assert($1 == nil, $1!.localizedDescription) }
            operation.completionBlock = { [weak self] in
                self?.itemsSubject.value = result.compactMap { self?.mapper.map($0).toItem() }
                promise(.success(()))
            }

            self?.database.add(operation)
        }
    }

    public func update(_ item: Item) -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self = self, let record = self.mapper.map(item).toRecord() else { return }

            self.database.fetch(withRecordID: record.recordID) { record, error in
                assert(error == nil, error!.localizedDescription)
                guard let updatedRecord = self.mapper.map(record).updateBy(item).toRecord() else { return }
                self.database.save(updatedRecord) { record, error in
                    assert(error == nil, error!.localizedDescription)
                    guard let index = self.indexForItem(item) else { return }
                    self.itemsSubject.value[index] = self.mapper.map(record).toItem() ?? item

                    DispatchQueue.main.async { promise(.success(())) }
                }
            }
        }
    }

    public func delete(_ items: [Item]) -> Future<Void, Never> {
        deleteItems(items)
    }

    public func deleteAll() -> Future<Void, Never> {
        deleteItems(itemsSubject.value)
    }

    private func deleteItems(_ items: [Item]) -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }

            let recordIds = items.compactMap { self.mapper.map($0).toRecord()?.recordID }
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
            operation.modifyRecordsCompletionBlock = { _, deletedRecordIds, _ in
                guard let deletedRecordIds = deletedRecordIds else { return }
                let deletedItemIds = deletedRecordIds.compactMap { UUID(uuidString: $0.recordName) }
                self.itemsSubject.value = self.itemsSubject.value.filter { !deletedItemIds.contains($0.id) }
            }
            operation.completionBlock = {
                DispatchQueue.main.async { promise(.success(())) }
            }

            self.database.add(operation)
        }
    }

    private func indexForItem(_ item: Item) -> Int? {
        itemsSubject.value.firstIndex { $0.id == item.id }
    }

    private func registerSubscriptionIfNeeded() {
        subscriptionService.registerIfNeeded(.itemSubscription)
    }

    private func registerNotification() {
        notificationCenter.publisher(for: .itemUpdateReceived)
            .sink { [weak self] _ in _ = self?.refresh() }
            .store(in: &subscriptions)
    }
}
