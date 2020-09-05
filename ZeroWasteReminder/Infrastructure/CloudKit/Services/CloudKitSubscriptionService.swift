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

    public func registerItemsSubscriptionIfNeeded() {
        statusNotifier.remoteStatus
            .filter { $0 == .connected }
            .first()
            .setFailureType(to: CKError.self)
            .flatMap { [weak self] _ -> AnyPublisher<Bool, CKError> in
                guard let self = self else {
                    return Empty<Bool, CKError>().eraseToAnyPublisher()
                }
                return self.hasItemSubscription().eraseToAnyPublisher()
            }
            .filter { $0 == false }
            .flatMap { [weak self] _ -> AnyPublisher<Void, CKError> in
                guard let self = self else {
                    return Empty<Void, CKError>().eraseToAnyPublisher()
                }
                return self.saveItemSubscription().eraseToAnyPublisher()
            }
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .cancel()
    }

    private func hasItemSubscription() -> Future<Bool, CKError> {
        Future { [weak self] promise in
            self?.database.fetchAllSubscriptions(completionHandler: { subscriptions, error in
                if let error = error as? CKError {
                    promise(.failure(error))
                } else {
                    promise(.success(subscriptions?.first { $0.notificationInfo?.category == "Item" } != nil))
                }
            })
        }
    }

    private func saveItemSubscription() -> Future<Void, CKError> {
        Future { [weak self] promise in
            self?.database.save(CKQuerySubscription.itemSubscription) { _, error in
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
        let subscription = CKQuerySubscription(
            recordType: "Item",
            predicate: .init(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let notificationInfo = CKQuerySubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.category = "Item"

        subscription.notificationInfo = notificationInfo
        return subscription
    }
}
