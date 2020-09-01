public protocol ListsChangeListener {
    func releaseChangedListIds() -> [Id<List>]

    func startListening(in list: List)
    func stopListening()
}
