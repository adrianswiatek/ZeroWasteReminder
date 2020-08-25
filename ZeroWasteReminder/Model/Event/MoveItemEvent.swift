public enum MoveItemEvent {
    case error(_ error: AppError)
    case fetched(_ lists: [List])
    case moved(_ item: Item)
}
