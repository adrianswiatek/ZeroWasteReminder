import Combine
import CloudKit

public final class CloudKitSubscriptionService: SubscriptionService {
    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private let configuration: CloudKitConfiguration
    private let statusNotifier: StatusNotifier


    public init(configuration: CloudKitConfiguration, statusNotifier: StatusNotifier) {
        self.configuration = configuration
        self.statusNotifier = statusNotifier
    }

    public func registerSubscriptionsIfNeeded() {
        statusNotifier.remoteStatus
            .filter { $0 == .connected }
            .first()
            .setFailureType(to: CKError.self)
            .flatMap { [weak self] _ -> AnyPublisher<[CKSubscription], CKError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.fetchAllSubscriptions().eraseToAnyPublisher()
            }
            .flatMap { [weak self] subscriptions -> AnyPublisher<Void, CKError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let querySubscriptionsToSave = self.determineQuerySubscriptionsToSave(from: subscriptions)
                return self.saveSubscriptions(querySubscriptionsToSave).eraseToAnyPublisher()
            }
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .cancel()
    }

    private func fetchAllSubscriptions() -> Future<[CKSubscription], CKError> {
        Future { [weak self] promise in
            self?.database.fetchAllSubscriptions(completionHandler: { subscriptions, error in
                if let error = error as? CKError {
                    promise(.failure(error))
                } else {
                    promise(.success(subscriptions ?? []))
                }
            })
        }
    }

    private func determineQuerySubscriptionsToSave(from subscriptions: [CKSubscription]) -> [CKQuerySubscription] {
        let categories = subscriptions.compactMap { $0.notificationInfo?.category }
        var result = [CKQuerySubscription]()

        if !categories.contains("List") {
            result.append(.listSubscription)
        }

        if !categories.contains("Item") {
            result.append(.itemSubscription)
        }

        return result
    }

    private func saveSubscriptions(_ subscriptions: [CKQuerySubscription]) -> Future<Void, CKError> {
        Future { [weak self] promise in
            let operation = CKModifySubscriptionsOperation(
                subscriptionsToSave: subscriptions,
                subscriptionIDsToDelete: nil
            )

            operation.modifySubscriptionsCompletionBlock = {
                if let error = $2 as? CKError {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }

            self?.database.add(operation)
        }
    }
}

private extension CKQuerySubscription {
    static var itemSubscription: CKQuerySubscription {
        subscription(recordType: "Item", desiredKeys: [CloudKitKey.Item.listReference])
    }

    static var listSubscription: CKQuerySubscription {
        subscription(recordType: "List")
    }

    static func subscription(recordType: String, desiredKeys: [CKRecord.FieldKey] = []) -> CKQuerySubscription {
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: .init(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let notificationInfo = CKQuerySubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.category = recordType
        notificationInfo.desiredKeys = desiredKeys

        subscription.notificationInfo = notificationInfo
        return subscription
    }
}
