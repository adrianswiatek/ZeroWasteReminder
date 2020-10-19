import CoreData

internal struct CoreDataNotificationEntityMapper {
    private let entity: NotificationEntity

    internal init(_ entity: NotificationEntity) {
        self.entity = entity
    }

    internal func toNotification() -> ItemNotification {
        .init(
            itemId: .fromUuid(entity.itemId!),
            listId: .fromUuid(entity.listId!),
            itemName: entity.itemName!,
            expiration: .fromDate(entity.expirationDate!),
            alertOption: .fromString(entity.alertOption!)
        )
    }
}
