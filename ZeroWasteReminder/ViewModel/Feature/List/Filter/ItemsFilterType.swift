public enum ItemsFilterType: String, CaseIterable {
    case all = "All"
    case notDefined = "Not defined"
    case expired = "Expired"
    case aboutToExpire = "About to expire"
    case beforeExpiration = "Before expiration"
}

extension ItemsFilterType: CustomStringConvertible {
    public var description: String {
        self.rawValue
    }
}
