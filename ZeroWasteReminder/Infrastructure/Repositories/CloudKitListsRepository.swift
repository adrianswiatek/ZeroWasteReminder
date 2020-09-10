import CloudKit
import Combine

public final class CloudKitListsRepository: ListsRepository {
    private let database: CKDatabase
    private let zone: CKRecordZone
    private let mapper: CloudKitMapper
    private let cache: CloudKitCache
    private let eventDispatcher: EventDispatcher

    private var updateSubscription: AnyCancellable?

    public init(
        configuration: CloudKitConfiguration,
        cache: CloudKitCache,
        mapper: CloudKitMapper,
        eventDispatcher: EventDispatcher
    ) {
        self.database = configuration.container.database(with: .private)
        self.zone = configuration.appZone
        self.mapper = mapper
        self.cache = cache
        self.eventDispatcher = eventDispatcher
    }

    public func fetchAll() {
        let query = CKQuery(recordType: "List", predicate: .init(value: true))
        let operation = CKQueryOperation(query: query)

        var records = [CKRecord]()

        operation.recordFetchedBlock = {
            records.append($0)
        }

        operation.completionBlock = { [weak self] in
            self?.cache.invalidate()
            self?.cache.set(records)

            let lists = records.compactMap { self?.mapper.map($0).toList() }
            self?.eventDispatcher.dispatch(ListsFetched(lists))
        }

        operation.queryCompletionBlock = { [weak self] in
            $1.map { self?.eventDispatcher.dispatch(ErrorOccured(.init($0))) }
        }

        database.add(operation)
    }

    public func add(_ list: List) {
        guard let record = mapper.map(list).toRecordInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { [weak self] in
            if let error = $2 {
                self?.eventDispatcher.dispatch(ErrorOccured(.init(error)))
            } else if let list = self?.mapper.map($0?.first).toList() {
                $0?.first.map { self?.cache.set($0) }
                self?.eventDispatcher.dispatch(ListAdded(list))
            } else {
                self?.eventDispatcher.dispatch(NoResultOccured())
            }
        }

        database.add(operation)
    }

    public func remove(_ list: List) {
        guard let recordId = mapper.map(list).toRecordIdInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordId])
        operation.modifyRecordsCompletionBlock = { [weak self] in
            let id: Id<List>? = $1?.first.map { .fromString($0.recordName) }
            if let error = $2 {
                self?.eventDispatcher.dispatch(ErrorOccured(.init(error)))
            } else if id == list.id {
                $1?.first.map { self?.cache.removeById($0) }
                self?.eventDispatcher.dispatch(ListRemoved(list))
            } else {
                self?.eventDispatcher.dispatch(NoResultOccured())
            }
        }

        database.add(operation)
    }

    public func update(_ list: List) {
        update([list])
    }

    public func update(_ lists: [List]) {
        let recordIds = lists.compactMap { mapper.map($0).toRecordIdInZone(zone) }
        guard !recordIds.isEmpty else { return eventDispatcher.dispatch(NoResultOccured()) }

        updateSubscription = fetchRecords(with: recordIds)
            .flatMap { [weak self] records -> AnyPublisher<[CKRecord], Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.update(records, by: lists).eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] in
                    if case .failure(let error) = $0 {
                        self?.eventDispatcher.dispatch(ErrorOccured(.init(error)))
                    }
                    self?.updateSubscription = nil
                },
                receiveValue: { [weak self] in
                    let lists = $0.compactMap { self?.mapper.map($0).toList() }
                    if lists.isEmpty {
                        self?.eventDispatcher.dispatch(NoResultOccured())
                    } else {
                        self?.cache.set($0)
                        self?.eventDispatcher.dispatch(ListsUpdated(lists))
                    }
                }
            )
    }

    private func fetchRecords(with ids: [CKRecord.ID]) -> Future<[CKRecord], Error> {
        Future { [weak self] promise in
            if let records = self?.cache.findByIds(ids), records.count == ids.count {
                return promise(.success(records))
            }

            let query = CKQuery(recordType: "List", predicate: .init(format: "%K IN %@", "recordID", ids))
            let operation = CKQueryOperation(query: query)

            var records: [CKRecord] = []
            var error: Error? = nil

            operation.recordFetchedBlock = { records.append($0) }
            operation.queryCompletionBlock = { error = $1 }

            operation.completionBlock = {
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(records))
                }
            }

            self?.database.add(operation)
        }
     }

    private func update(_ records: [CKRecord], by lists: [List]) -> Future<[CKRecord], Error> {
        Future { [weak self] promise in
            let updatedRecords: [CKRecord] = records.compactMap { record in
                let list = lists.first { $0.id == .fromString(record.recordID.recordName) }
                return self?.mapper.map(record).updatedBy(list).toRecord()
            }

            let operation = CKModifyRecordsOperation(recordsToSave: updatedRecords)
            operation.savePolicy = .changedKeys

            var records: [CKRecord] = []
            var error: Error? = nil

            operation.perRecordCompletionBlock = {
                records.append($0)
                error = $1
            }

            operation.completionBlock = {
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(records))
                }
            }

            self?.database.add(operation)
        }
    }
}
