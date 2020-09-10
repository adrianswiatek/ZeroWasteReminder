public struct ListRemoved: AppEvent {
    public let list: List

    public init(_ list: List) {
        self.list = list
    }
}
