public enum ItemsEvent {
    case added(_ item: Item)
    case fetched(_ items: [Item])
    case finishedWithoutResult
    case removed(_ items: [Item])
    case updated(_ item: Item)

    public static func removed(_ item: Item) -> ItemsEvent {
        return removed([item])
    }
}
