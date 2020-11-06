import Combine
import CloudKit

public final class CloudKitSubscriptionService: SubscriptionService {
    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private let configuration: CloudKitConfiguration
    private let statusNotifier: StatusNotifier
    private var subscriptions: Set<AnyCancellable>

    public init(configuration: CloudKitConfiguration, statusNotifier: StatusNotifier) {
        self.configuration = configuration
        self.statusNotifier = statusNotifier
        self.subscriptions = []
    }

    public func registerSubscriptionsIfNeeded() {
        statusNotifier.remoteStatus
            .filter { $0 == .connected }
            .first()
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ -> AnyPublisher<[CKSubscription], Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.fetchAllSubscriptions().eraseToAnyPublisher()
            }
            .flatMap { [weak self] subscriptions -> AnyPublisher<Void, Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let querySubscriptionsToSave = self.determineQuerySubscriptionsToSave(from: subscriptions)
                return self.saveSubscriptions(querySubscriptionsToSave).eraseToAnyPublisher()
            }
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .store(in: &subscriptions)
    }

    private func fetchAllSubscriptions() -> Future<[CKSubscription], Error> {
        Future { [weak self] promise in
            self?.database.fetchAllSubscriptions(completionHandler: { subscriptions, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(subscriptions ?? []))
                }
            })
        }
    }

    private func determineQuerySubscriptionsToSave(from subscriptions: [CKSubscription]) -> [CKQuerySubscription] {
        let categories = subscriptions
            .compactMap { $0.notificationInfo?.category }

        return Subscription.allCases
            .filter { !categories.contains($0.rawValue) }
            .map { $0.asCKQuerySubscription() }
    }

    private func saveSubscriptions(_ subscriptions: [CKQuerySubscription]) -> Future<Void, Error> {
        Future { [weak self] promise in
            let operation = CKModifySubscriptionsOperation(
                subscriptionsToSave: subscriptions,
                subscriptionIDsToDelete: nil
            )

            operation.modifySubscriptionsCompletionBlock = {
                promise($2 != nil ? .failure($2!) : .success(()))
            }

            self?.database.add(operation)
        }
    }
}

private extension CloudKitSubscriptionService {
    enum Subscription: String, CaseIterable {
        case item = "Item"
        case list = "List"
        case photo = "Photo"

        func asCKQuerySubscription() -> CKQuerySubscription {
            let subscriptionWithKeys = subscription(for: rawValue)

            switch self {
            case .item: return subscriptionWithKeys(.just(CloudKitKey.Item.listReference))
            case .list: return subscriptionWithKeys(.empty)
            case .photo: return subscriptionWithKeys(.just(CloudKitKey.Photo.itemReference))
            }
        }

        private func subscription(
            for recordType: String
        ) -> ([CKRecord.FieldKey]) -> CKQuerySubscription {
            return { desiredKeys in
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
    }
}
