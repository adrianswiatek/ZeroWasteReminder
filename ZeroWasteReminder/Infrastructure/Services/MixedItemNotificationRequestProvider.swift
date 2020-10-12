public final class ShortItemNotificationIdentifierProvider: ItemNotificationIdentifierProvider {
    public func provide(from item: Item) -> String {
        provide(from: item.id.asString) + Constant.midstSign + provide(from: item.listId.asString)
    }

    public func `is`(_ listId: Id<List>, partOf itemNotificationIdentifier: String) -> Bool {
        assertIdentifier(itemNotificationIdentifier)
        return itemNotificationIdentifier.contains(provide(from: listId.asString))
    }

    private func provide(from id: String) -> String {
        String(id.split(separator: Constant.uuidSeparator, maxSplits: 1)[0])
    }

    private func assertIdentifier(_ identifier: String) {
        assert(identifier.isEmpty == false)
        assert(identifier.contains(Constant.midstSign))
        assert(identifier.count == provide(from: Id<Item>.fromUuid(.empty).asString).count * 2 + 1)
    }
}

private extension ShortItemNotificationIdentifierProvider {
    enum Constant {
        static let midstSign: String = "+"
        static let uuidSeparator: Character = "-"
    }
}
