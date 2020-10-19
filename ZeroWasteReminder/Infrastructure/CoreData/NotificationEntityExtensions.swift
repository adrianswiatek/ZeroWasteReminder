extension NotificationEntity {
    internal func updateBy(_ item: Item) {
        precondition(item.expiration.date != nil, "Expiration date must have value.")

        itemId = item.id.asUuid
        listId = item.listId.asUuid
        itemName = item.name
        expirationDate = item.expiration.date
        alertOption = item.alertOption.asString
    }
}
