import Combine

public struct ItemsFilterCellViewModel: Hashable {
    public let isSelected: Bool
    public let remainingState: RemainingState

    public var title: String {
        switch remainingState {
        case .notDefined: return "Not defined"
        case .expired: return "Expired"
        case .almostExpired: return "Almost expired"
        case .valid(_, _): return "Valid"
        }
    }

    public init(_ remainingState: RemainingState) {
        self.init(remainingState, isSelected: false)
    }

    private init(_ remainingState: RemainingState, isSelected: Bool) {
        self.remainingState = remainingState
        self.isSelected = isSelected
    }

    public func toggled() -> Self {
        .init(remainingState, isSelected: !isSelected)
    }

    public func deselected() -> Self {
        .init(remainingState, isSelected: false)
    }

    public func filter(_ items: [Item]) -> [Item] {
        guard isSelected else {
            return []
        }

        if case .valid(_, _) = remainingState {
            let invalidStates: [RemainingState] = [.notDefined, .expired, .almostExpired]
            return items.filter { !invalidStates.contains(RemainingState(expiration: $0.expiration)) }
        }

        return items.filter { RemainingState(expiration: $0.expiration) == remainingState }
    }
}
