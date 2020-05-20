import CloudKit

extension CKQuerySubscription {
    public static var itemSubscription: CKQuerySubscription {
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
