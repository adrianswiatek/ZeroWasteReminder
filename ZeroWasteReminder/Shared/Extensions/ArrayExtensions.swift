extension Array where Element: Equatable {
    public func removedAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Self {
        var array = self
        try array.removeAll(where: shouldBeRemoved)
        return array
    }
}
