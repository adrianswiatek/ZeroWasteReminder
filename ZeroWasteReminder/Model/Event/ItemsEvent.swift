public enum ItemsEvent {
    case added(_ item: Item)
    case error(_ error: AppError)
    case fetched(_ items: [Item])
    case removed(_ items: [Item])
    case updated(_ item: Item)

    public static func removed(_ item: Item) -> ItemsEvent {
        return removed([item])
    }
}
