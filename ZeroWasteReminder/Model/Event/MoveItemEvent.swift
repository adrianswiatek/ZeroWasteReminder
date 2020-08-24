public enum MoveItemEvent {
    case fetched(_ lists: [List])
    case moved(_ item: Item)
}
