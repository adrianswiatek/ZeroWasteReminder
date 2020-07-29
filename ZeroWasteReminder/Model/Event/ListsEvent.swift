public enum ListsEvent {
    case added(_ list: List)
    case fetched(_ lists: [List])
    case removed(_ list: List)
    case updated(_ list: List)
}