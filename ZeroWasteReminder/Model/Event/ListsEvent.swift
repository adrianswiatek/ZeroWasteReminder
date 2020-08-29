public enum ListsEvent {
    case added(_ list: List)
    case error(_ error: AppError)
    case fetched(_ lists: [List])
    case noResult
    case removed(_ list: List)
    case updated(_ lists: [List])

    public static func updated(_ list: List) -> ListsEvent {
        .updated([list])
    }
}
