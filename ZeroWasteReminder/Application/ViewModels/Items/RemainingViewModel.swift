public final class RemainingViewModel {
    public var formattedValue: String {
        switch state {
        case .notDefined:
            return ""
        case .expired:
            return String.localized(.expired).lowercased()
        case .almostExpired:
            return String.localized(.almostExpired).lowercased()
        case let .valid(value, component):
            return component.format(forValue: value)
        }
    }

    public var state: RemainingState

    public init(_ item: Item) {
        state = .init(expiration: item.expiration)
    }
}
