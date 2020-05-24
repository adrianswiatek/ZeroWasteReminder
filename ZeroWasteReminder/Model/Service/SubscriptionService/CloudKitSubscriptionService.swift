import Combine
import CloudKit

public final class CloudKitSubscriptionService: SubscriptionService {
    private let database: CKDatabase
    private var subscriptions: Set<AnyCancellable>

    public init(_ container: CKContainer) {
        database = container.privateCloudDatabase
        subscriptions = []
    }

    public func registerItemsSubscriptionIfNeeded() {
        existingItemSubscription()
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        print(error)
                    }
                },
                receiveValue: { [weak self] itemSubscription in
                    guard let self = self, itemSubscription == nil else { return }

                    self.database.save(CKQuerySubscription.itemSubscription) { _, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            )
            .store(in: &subscriptions)
    }

    private func existingItemSubscription() -> Future<CKSubscription?, CKError> {
        Future { [weak self] promise in
            self?.database.fetchAllSubscriptions(completionHandler: { subscriptions, error in
                if let error = error as? CKError {
                    promise(.failure(error))
                    return
                }

                let itemSubscription = subscriptions?.first { $0.notificationInfo?.category == "Item" }
                promise(.success(itemSubscription))
            })
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
