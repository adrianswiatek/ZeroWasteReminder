public struct ItemsFilterCellViewModel: Hashable {
    public let isSelected: Bool
    public let remainingState: RemainingState

    public var title: String {
        switch remainingState {
        case .notDefined: return .localized(.notDefined)
        case .expired: return .localized(.expired)
        case .almostExpired: return .localized(.almostExpired)
        case .valid: return .localized(.valid)
        }
    }

    public init(_ remainingState: RemainingState) {
        self.init(remainingState, isSelected: false)
    }

    private init(_ remainingState: RemainingState, isSelected: Bool) {
        self.remainingState = remainingState
        self.isSelected = isSelected
    }

    public func toggled() -> ItemsFilterCellViewModel {
        .init(remainingState, isSelected: !isSelected)
    }

    public func deselected() -> ItemsFilterCellViewModel {
        isSelected ? .init(remainingState, isSelected: false) : self
    }

    public func filter(_ items: [Item]) -> [Item] {
        guard isSelected else {
            return []
        }

        if case .valid = remainingState {
            let invalidStates: [RemainingState] = [.notDefined, .expired, .almostExpired]
            return items.filter { !invalidStates.contains(RemainingState(expiration: $0.expiration)) }
        }

        return items.filter { RemainingState(expiration: $0.expiration) == remainingState }
    }
}
