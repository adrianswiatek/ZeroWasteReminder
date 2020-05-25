import CloudKit
import Combine

public final class CloudKitItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private var zone: CKRecordZone {
        configuration.itemsZone
    }

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let mapper: CloudKitMapper
    private let notificationCenter: NotificationCenter
    private let configuration: CloudKitConfiguration

    private var subscriptions: Set<AnyCancellable>

    public init(
        configuration: CloudKitConfiguration,
        mapper: CloudKitMapper,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = configuration
        self.mapper = mapper
        self.notificationCenter = notificationCenter

        self.itemsSubject = .init([])
        self.subscriptions = []

        self.registerNotification()
    }

    public func add(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self, let record = self.mapper.map(item).toRecordInZone(self.zone) else { return }

            let operation = CKModifyRecordsOperation(recordsToSave: [record])
            operation.modifyRecordsCompletionBlock = { records, _, error in
                if let error = error {
                    DispatchQueue.main.async { promise(.failure(.init(error))) }
                } else if let record = records?.first, let item = self.mapper.map(record).toItem() {
                    self.itemsSubject.value = self.itemsSubject.value + [item]
                    DispatchQueue.main.async { promise(.success(())) }
                }
            }

            self.database.add(operation)
        }
    }

    public func refresh() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            var result = [CKRecord]()

            let operation = CKQueryOperation(query: .init(recordType: "Item", predicate: .init(value: true)))
            operation.recordFetchedBlock = { result.append($0) }
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    self?.itemsSubject.value = result.compactMap { self?.mapper.map($0).toItem() }
                    DispatchQueue.main.async { promise(.success(())) }
                }
            }

            self?.database.add(operation)
        }
    }

    public func update(_ item: Item) -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self = self, let record = self.mapper.map(item).toRecordInZone(self.zone) else { return }

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

    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
        deleteItems(items)
    }

    public func deleteAll() -> Future<Void, ServiceError> {
        deleteItems(itemsSubject.value)
    }

    private func deleteItems(_ items: [Item]) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            let recordIds = items.compactMap { self.mapper.map($0).toRecordInZone(self.zone)?.recordID }
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
            operation.modifyRecordsCompletionBlock = { _, deletedRecordIds, error in
                if let error = error {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else if let deletedRecordIds = deletedRecordIds {
                    let deletedItemIds = deletedRecordIds.compactMap { UUID(uuidString: $0.recordName) }
                    self.itemsSubject.value = self.itemsSubject.value.filter { !deletedItemIds.contains($0.id) }
                }
                DispatchQueue.main.async { promise(.success(())) }
            }

            self.database.add(operation)
        }
    }

    private func indexForItem(_ item: Item) -> Int? {
        itemsSubject.value.firstIndex { $0.id == item.id }
    }

    private func registerNotification() {
        notificationCenter.publisher(for: .itemUpdateReceived)
            .sink { [weak self] _ in _ = self?.refresh() }
            .store(in: &subscriptions)
    }
}
