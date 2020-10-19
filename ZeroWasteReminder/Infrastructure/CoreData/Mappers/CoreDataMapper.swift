public struct CoreDataMapper {
    internal func map(_ entity: NotificationEntity) -> CoreDataNotificationEntityMapper {
        .init(entity)
    }
}
