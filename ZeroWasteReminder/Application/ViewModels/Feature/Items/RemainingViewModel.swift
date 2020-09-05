public final class RemainingViewModel {
    public var formattedValue: String {
        switch state {
        case .notDefined:
            return ""
        case .expired:
            return "expired"
        case .almostExpired:
            return "almost expired"
        case let .valid(value, component):
            return component.format(forValue: value)
        }
    }

    public var state: RemainingState

    public init(_ item: Item) {
        state = .init(expiration: item.expiration)
    }
}
