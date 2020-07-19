public enum ItemsEvent {
    case added(_ item: Item)
    case fetched(_ items: [Item])
    case removed(_ items: [Item])
    case updated(_ item: Item)
}
