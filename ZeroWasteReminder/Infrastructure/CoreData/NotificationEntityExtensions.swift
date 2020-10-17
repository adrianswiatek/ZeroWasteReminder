extension NotificationEntity {
    internal func updateBy(_ item: Item) {
        itemId = item.id.asUuid
        listId = item.listId.asUuid
        alertOption = item.alertOption.asString
    }
}
