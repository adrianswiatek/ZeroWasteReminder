import CoreData

internal struct CoreDataNotificationEntityMapper {
    private let entity: NotificationEntity

    internal init(_ entity: NotificationEntity) {
        self.entity = entity
    }

    internal func toNotification() -> Notification {
        .init(
            itemId: .fromUuid(entity.itemId!),
            listId: .fromUuid(entity.listId!),
            alertOption: .fromString(entity.alertOption!)
        )
    }
}
