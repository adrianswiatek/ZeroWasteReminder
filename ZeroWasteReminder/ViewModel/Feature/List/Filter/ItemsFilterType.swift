public enum ItemsFilterType: String, CaseIterable {
    case all = "All"
    case notDefined = "Not defined"
    case expired = "Expired"
    case almostExpired = "Almost expired"
    case beforeExpiration = "Before expiration"
}

extension ItemsFilterType: CustomStringConvertible {
    public var description: String {
        self.rawValue
    }
}
