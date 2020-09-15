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

    public func registerListsSubscriptionIfNeeded() {
        statusNotifier.remoteStatus
            .filter { $0 == .connected }
            .first()
            .setFailureType(to: CKError.self)
            .flatMap { [weak self] _ -> AnyPublisher<Bool, CKError> in
                guard let self = self else {
                    return Empty<Bool, CKError>().eraseToAnyPublisher()
                }
                return self.hasSubscription(with: "Item").eraseToAnyPublisher()
            }
            .flatMap { [weak self] hasSubscription -> AnyPublisher<Void, CKError> in
                guard let self = self, !hasSubscription else {
                    return Empty<Void, CKError>().eraseToAnyPublisher()
                }
                return self.saveSubscription(CKQuerySubscription.itemSubscription).eraseToAnyPublisher()
            }
            .flatMap { [weak self] _ -> AnyPublisher<Bool, CKError> in
                guard let self = self else {
                    return Empty<Bool, CKError>().eraseToAnyPublisher()
                }
                return self.hasSubscription(with: "List").eraseToAnyPublisher()
            }
            .flatMap { [weak self] hasSubscription -> AnyPublisher<Void, CKError> in
                guard let self = self, !hasSubscription else {
                    return Empty<Void, CKError>().eraseToAnyPublisher()
                }
                return self.saveSubscription(CKQuerySubscription.listSubscription).eraseToAnyPublisher()
            }
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .cancel()
    }

    private func hasSubscription(with category: String) -> Future<Bool, CKError> {
        Future { [weak self] promise in
            self?.database.fetchAllSubscriptions(completionHandler: { subscriptions, error in
                if let error = error as? CKError {
                    promise(.failure(error))
                } else {
                    promise(.success(subscriptions?.first { $0.notificationInfo?.category == category } != nil))
                }
            })
        }
    }

    private func saveSubscription(_ subscription: CKQuerySubscription) -> Future<Void, CKError> {
        Future { [weak self] promise in
            self?.database.save(subscription) { _, error in
                if let error = error as? CKError {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
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
