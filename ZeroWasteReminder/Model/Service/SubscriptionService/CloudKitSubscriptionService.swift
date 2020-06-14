import Combine
import CloudKit

public final class CloudKitSubscriptionService: SubscriptionService {
    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private let configuration: CloudKitConfiguration

    public init(configuration: CloudKitConfiguration) {
        self.configuration = configuration
    }

    public func registerItemsSubscriptionIfNeeded() {
        hasItemSubscription()
            .flatMap { [weak self] hasItemSubscription -> AnyPublisher<Void, CKError> in
                guard let self = self, !hasItemSubscription else {
                    return Empty<Void, CKError>().eraseToAnyPublisher()
                }
                return self.saveItemSubscription().eraseToAnyPublisher()
            }
            .subscribe(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        assertionFailure(error.localizedDescription)
                    }
                },
                receiveValue: {})
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
